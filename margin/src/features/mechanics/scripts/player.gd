class_name Player
extends CharacterBody2D
## Player rig: lunar movement + the core tool trio (jetpack, tether, spikes).
## Every tuned value traces to doc/research/movement_and_protection.md and
## doc/research/movement-tools.md — keep the trace, update research together.
## Extra movement tools (drone/bridge/ascender/winch) are FLAGGED pending the
## propulsion decision — do not add them here until the team decides.

enum State { MOVE, SWING, CLIMB }

const G0 := 9.80665  # standard gravity, for the rocket-equation propellant drain

const TOOL_JETPACK := preload("res://src/features/mechanics/resources/tool_jetpack.tres")
const TOOL_TETHER := preload("res://src/features/mechanics/resources/tool_tether.tres")
const TOOL_SPIKES := preload("res://src/features/mechanics/resources/tool_spikes.tres")

var state: State = State.MOVE
var propellant_kg: float = GameConstants.JETPACK_PROPELLANT_KG
var heat: float = 0.0
var chill: float = 0.0
var radiation: float = 0.0
var mission_over := false

var _coyote := 0.0
var _jump_buffer := 0.0
var _thrusting := false
var _active_zones: Dictionary = {}  # zone_id -> true (via EventBus.hazard_entered)
var _slip_timer := 0.0              # spikes slip timer inside LooseRegolith zones
var _climb_grace := 0.0             # grace after a wall jump so we don't re-cling

# tether swing state
var _anchor_point := Vector2.ZERO
var _rope_len := 0.0

@onready var _rope: Line2D = $TetherRope


func _ready() -> void:
	propellant_kg = TOOL_JETPACK.propellant_kg
	EventBus.hazard_entered.connect(_on_hazard_entered)
	EventBus.hazard_exited.connect(_on_hazard_exited)
	_announce_equipped()


# ---------------------------------------------------------------- movement --

func _physics_process(delta: float) -> void:
	if mission_over:
		return
	_jump_buffer = maxf(0.0, _jump_buffer - delta)
	_climb_grace = maxf(0.0, _climb_grace - delta)
	if Input.is_action_just_pressed(&"jump"):
		_jump_buffer = GameConstants.JUMP_BUFFER_S

	match state:
		State.MOVE:
			_process_move(delta)
		State.SWING:
			_process_swing(delta)
		State.CLIMB:
			_process_climb(delta)

	_update_hazards(delta)
	move_and_slide()

	# A climb ends when there is no wall left to hold.
	if state == State.CLIMB and _climb_grace <= 0.0 and not is_on_wall():
		state = State.MOVE
		_slip_timer = 0.0

	_rope.visible = state == State.SWING
	if _rope.visible:
		_rope.points = PackedVector2Array([Vector2.ZERO, _rope.to_local(_anchor_point)])


func _process_move(delta: float) -> void:
	var input_x := Input.get_axis(&"move_left", &"move_right")
	var speed := GameConstants.WALK_SPEED_MSS * GameConstants.WORLD_PPM * _mass_factor()
	var accel := (GameConstants.GROUND_ACCEL_MSS if is_on_floor() else GameConstants.AIR_ACCEL_MSS) * GameConstants.WORLD_PPM
	velocity.x = move_toward(velocity.x, input_x * speed, accel * delta)
	velocity.y = minf(velocity.y + GameConstants.MOON_GRAVITY_PXS * delta, GameConstants.TERMINAL_FALL_PXS)

	# book.low_gravity: h = v^2 / (2g) — 3 m/s launch reaches ~2.78 m on the Moon.
	if is_on_floor():
		_coyote = GameConstants.COYOTE_TIME_S
	else:
		_coyote = maxf(0.0, _coyote - delta)
	if _jump_buffer > 0.0 and _coyote > 0.0:
		velocity.y = -GameConstants.JUMP_SPEED_MSS * GameConstants.WORLD_PPM * _mass_factor()
		_jump_buffer = 0.0
		_coyote = 0.0

	_jetpack(delta)

	if Input.is_action_just_pressed(&"tether_fire") and _has_tool(&"tool.tether"):
		_try_fire_tether()
	elif Input.is_action_just_pressed(&"spikes_deploy") and _has_tool(&"tool.spikes") and is_on_wall():
		_enter_climb()


# ---------------------------------------------------------------- jetpack --

## book.mass.rocket_equation: thrust is limited and propellant drains by
## mdot = F / (Isp * g0). Thrust accel = F / m_total, so draining the tanks
## makes the (lighter) system accelerate faster — the trade-off made visible.
func _jetpack(delta: float) -> void:
	if not _has_tool(&"tool.jetpack") or propellant_kg <= 0.0:
		_thrusting = false
		return
	if not Input.is_action_pressed(&"jetpack_thrust"):
		_thrusting = false
		return
	var dir := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if dir == Vector2.ZERO:
		dir = Vector2.UP
	var thrust_accel := TOOL_JETPACK.force_n / _total_mass_kg() * GameConstants.WORLD_PPM
	velocity += dir * thrust_accel * delta
	propellant_kg = maxf(0.0, propellant_kg - TOOL_JETPACK.force_n / (TOOL_JETPACK.isp_s * G0) * delta)
	if not _thrusting:
		_thrusting = true
		EventBus.tool_used.emit(&"tool.jetpack")


# ----------------------------------------------------------------- tether --

## Swing = taut-rope pendulum, computed by hand (no joint node) so the rope
## never snaps the physics solver and stays kid-forgiving.
func _try_fire_tether() -> void:
	# book.tether_tension: a slack arrest above this speed would spike tension;
	# the forgiving counter is that the hook skids off instead of snapping.
	if velocity.length() > GameConstants.TETHER_SLIP_SPEED_PXS:
		return
	var best: Node2D = null
	var best_d := GameConstants.TETHER_MAX_ROPE_PXS
	for node in get_tree().get_nodes_in_group(&"tether_anchor"):
		var anchor := node as Node2D
		if anchor == null:
			continue
		# Anchors well below the player are not swings; skip them.
		if anchor.global_position.y > global_position.y + 32.0:
			continue
		var d := global_position.distance_to(anchor.global_position)
		if d < best_d:
			best_d = d
			best = anchor
	if best == null:
		return
	state = State.SWING
	_anchor_point = best.global_position
	_rope_len = maxf(GameConstants.TETHER_MIN_ROPE_PXS, best_d)
	velocity = velocity.limit_length(GameConstants.TETHER_SLIP_SPEED_PXS)
	EventBus.tool_used.emit(&"tool.tether")


func _process_swing(delta: float) -> void:
	velocity.y += GameConstants.MOON_GRAVITY_PXS * delta

	# Kid-friendly pump: small tangential push with the move keys.
	var input_x := Input.get_axis(&"move_left", &"move_right")
	if input_x != 0.0:
		var to_anchor := _anchor_point - global_position
		if to_anchor.length() > 1.0:
			var tangent := Vector2(-to_anchor.y, to_anchor.x).normalized()
			velocity += tangent * input_x * GameConstants.SWING_PUMP_ACCEL_PXS * delta

	# Reel in / out with up / down.
	var reel := Input.get_axis(&"move_down", &"move_up")
	if reel != 0.0:
		_rope_len = clampf(
			_rope_len - reel * GameConstants.TETHER_REEL_SPEED_PXS * delta,
			GameConstants.TETHER_MIN_ROPE_PXS, GameConstants.TETHER_MAX_ROPE_PXS)

	# Taut-rope constraint: project onto the circle, strip radial velocity.
	var offset := global_position - _anchor_point
	var dist := offset.length()
	if dist > _rope_len:
		var n := offset / dist
		global_position = _anchor_point + n * _rope_len
		var radial := velocity.dot(n)
		if radial > 0.0:
			velocity -= n * radial

	# Release: F detaches, jump detaches with a small upward pop (fling).
	if Input.is_action_just_pressed(&"tether_fire"):
		state = State.MOVE
		_coyote = 0.0
	elif _jump_buffer > 0.0:
		_jump_buffer = 0.0
		velocity.y = minf(velocity.y, -GameConstants.JUMP_SPEED_MSS * GameConstants.WORLD_PPM * 0.6)
		state = State.MOVE
		_coyote = 0.0


# ----------------------------------------------------------------- spikes --

func _enter_climb() -> void:
	state = State.CLIMB
	_slip_timer = 0.0
	_climb_grace = 0.0
	velocity = velocity.limit_length(20.0)
	EventBus.tool_used.emit(&"tool.spikes")


func _detach_climb(knocked: bool = false) -> void:
	state = State.MOVE
	_slip_timer = 0.0
	if knocked and is_on_wall():
		velocity = get_wall_normal() * 40.0 + Vector2(0, 60.0)


func _process_climb(delta: float) -> void:
	var wall_normal := get_wall_normal()
	var into_wall := -wall_normal

	# Climb with up/down; no input = slow controlled slide (weakness trade-off).
	var up_down := Input.get_axis(&"move_down", &"move_up")
	var climb_speed := GameConstants.SPIKES_CLIMB_SPEED_MSS * GameConstants.WORLD_PPM
	if up_down != 0.0:
		velocity.y = move_toward(velocity.y, -up_down * climb_speed, climb_speed * 8.0 * delta)
	else:
		velocity.y = move_toward(velocity.y, GameConstants.SPIKES_SLIDE_SPEED_MSS * GameConstants.WORLD_PPM, climb_speed * 4.0 * delta)
	velocity.x = into_wall.x * 20.0  # keep pressed against the wall

	# Weakness (movement_and_protection.md): "very low pull-out resistance in
	# loose regolith" — inside a LooseRegolith zone the pitons work loose.
	if _active_zones.has(&"LooseRegolith"):
		_slip_timer += delta
		if _slip_timer >= GameConstants.SPIKES_REGOLITH_SLIP_S:
			_detach_climb(true)
			return
	else:
		_slip_timer = 0.0

	# Leaning away from the wall drops you off.
	var input_x := Input.get_axis(&"move_left", &"move_right")
	if input_x != 0.0 and signf(input_x) == signf(wall_normal.x):
		_detach_climb()
		return

	# Wall jump resets fall velocity — book.tether_tension counter:
	# "drive spikes into walls during a descent to reset fall velocity".
	if _jump_buffer > 0.0:
		_jump_buffer = 0.0
		velocity = wall_normal * GameConstants.WALL_JUMP_X_PXS \
				+ Vector2(0.0, -GameConstants.JUMP_SPEED_MSS * GameConstants.WORLD_PPM * 0.8)
		state = State.MOVE
		_climb_grace = 0.15
		return

	if Input.is_action_just_pressed(&"spikes_deploy"):
		_detach_climb()


# ---------------------------------------------------------------- hazards --

func _on_hazard_entered(zone_id: StringName) -> void:
	_active_zones[zone_id] = true


func _on_hazard_exited(zone_id: StringName) -> void:
	_active_zones.erase(zone_id)


## Forgiving accrual: hazard zones fill gauges slowly, leaving a zone recovers
## them passively (book.thermal.control: dart between shadows to cool down).
func _update_hazards(delta: float) -> void:
	var rates := {"heat": 0.0, "chill": 0.0, "radiation": 0.0}
	for zone_id: StringName in _active_zones:
		var zone_rates: Dictionary = GameConstants.HAZARD_RATES.get(zone_id, {})
		for key: String in zone_rates:
			rates[key] += zone_rates[key]

	if rates.heat > 0.0:
		heat = minf(heat + rates.heat * delta, GameConstants.HAZARD_FAIL_THRESHOLD)
	else:
		heat = maxf(heat - GameConstants.HAZARD_RECOVERY.heat * delta, 0.0)
	if rates.chill > 0.0:
		chill = minf(chill + rates.chill * delta, GameConstants.HAZARD_FAIL_THRESHOLD)
	else:
		chill = maxf(chill - GameConstants.HAZARD_RECOVERY.chill * delta, 0.0)
	if rates.radiation > 0.0:
		radiation = minf(radiation + rates.radiation * delta, GameConstants.HAZARD_FAIL_THRESHOLD)
	else:
		radiation = maxf(radiation - GameConstants.HAZARD_RECOVERY.radiation * delta, 0.0)

	if heat >= GameConstants.HAZARD_FAIL_THRESHOLD:
		_fail(&"book.thermal.control",
				"Suit thermal limit exceeded in the Solar Storm Zone. Shadows reset the suit — dart between them, or anchor the shelter.")
	elif chill >= GameConstants.HAZARD_FAIL_THRESHOLD:
		_fail(&"book.thermal.control",
				"Deep-cold exposure in the Permanent Shadow Zone. Cross shadows in short sprints — long hauls bleed the suit dry.")
	elif radiation >= GameConstants.HAZARD_FAIL_THRESHOLD:
		_fail(&"book.radiation.shielding",
				"Radiation dose maxed out in the Radioactive Wastes. Dose falls exponentially with areal density — sprint through, never slow-haul.")


func _fail(entry_id: StringName, reason: String) -> void:
	if mission_over:
		return
	mission_over = true
	BookOfBooks.add_note(entry_id, reason, {"heat": heat, "chill": chill, "radiation": radiation})
	EventBus.mission_failed.emit(entry_id, reason)


# -------------------------------------------------------------- loadout ---

func _total_mass_kg() -> float:
	var m := GameConstants.PLAYER_MASS_KG + GameConstants.SUIT_MASS_KG
	if _has_tool(&"tool.jetpack"):
		m += TOOL_JETPACK.mass_kg + propellant_kg
	return m


## Heavier loadout = slower walk, weaker jump (book.thermal.control trade-off:
## "expanding the cooling system ... slows down base walking speed").
func _mass_factor() -> float:
	var base := GameConstants.PLAYER_MASS_KG + GameConstants.SUIT_MASS_KG
	return sqrt(base / _total_mass_kg())


func _has_tool(tool_id: StringName) -> bool:
	# Test-bench convenience: an empty loadout means everything is usable.
	# A real mission always fills GameState.loadout from the hub.
	if GameState.loadout.is_empty():
		return true
	return GameState.loadout.has(tool_id)


func _announce_equipped() -> void:
	if GameState.loadout.is_empty():
		for tool in [TOOL_JETPACK, TOOL_TETHER, TOOL_SPIKES]:
			EventBus.tool_equipped.emit(tool.tool_id)
	else:
		for tool_id in GameState.loadout:
			EventBus.tool_equipped.emit(tool_id)
