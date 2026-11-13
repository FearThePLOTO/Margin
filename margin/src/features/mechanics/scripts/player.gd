class_name Player
extends CharacterBody2D
## Player rig: lunar movement + the tool trio (jetpack, tether, spikes) and
## the O2 supply (tool.o2).
## Thin coordinator: owns the state machine, cross-mechanic input buffering,
## move_and_slide() and shared helpers. Each mechanic lives in its own file
## (mechanic_*.gd, all RefCounted via player_mechanic.gd). Tuning is in raw
## pixels (no meter layer); doc/research/ is the reference story. Extra
## movement tools (drone/bridge/ascender/winch) are FLAGGED pending the
## propulsion decision — do not add them here until the team decides.

enum State { MOVE, SWING, CLIMB }

const TOOL_JETPACK := preload("res://src/features/mechanics/resources/tool_jetpack.tres")
const TOOL_TETHER := preload("res://src/features/mechanics/resources/tool_tether.tres")
const TOOL_SPIKES := preload("res://src/features/mechanics/resources/tool_spikes.tres")
const TOOL_O2 := preload("res://src/features/mechanics/resources/tool_o2.tres")

## Gauges stream to the mission HUD (ui feature) over EventBus at this rate —
## every physics tick is overkill for a display.
const GAUGE_EMIT_S := 0.1

var state: State = State.MOVE
var mission_over := false

# Cross-mechanic input grace / timers.
var jump_buffer := 0.0
var coyote := 0.0
var climb_grace := 0.0  # grace after a wall jump so we don't re-cling
var _gauge_emit := 0.0  # throttle for the HUD gauges stream

# Mechanics (RefCounted, one per file), wired in _ready.
var move: PlayerMoveMechanic
var jetpack: PlayerJetpackMechanic
var tether: PlayerTetherMechanic
var spikes: PlayerSpikesMechanic
var hazards: PlayerHazardsMechanic
var o2: PlayerO2Mechanic

@onready var rope: Line2D = $TetherRope
@onready var camera: Camera2D = $Camera2D


func _ready() -> void:
	move = PlayerMoveMechanic.new(self)
	jetpack = PlayerJetpackMechanic.new(self)
	tether = PlayerTetherMechanic.new(self)
	spikes = PlayerSpikesMechanic.new(self)
	hazards = PlayerHazardsMechanic.new(self)
	o2 = PlayerO2Mechanic.new(self)
	jetpack.propellant = TOOL_JETPACK.propellant
	_announce_equipped()


func _physics_process(delta: float) -> void:
	if mission_over:
		return
	jump_buffer = maxf(0.0, jump_buffer - delta)
	climb_grace = maxf(0.0, climb_grace - delta)
	if Input.is_action_just_pressed(&"jump"):
		jump_buffer = GameConstants.JUMP_BUFFER_S

	match state:
		State.MOVE:
			move.process(delta)
		State.SWING:
			tether.process(delta)
		State.CLIMB:
			spikes.process(delta)

	o2.process(delta)
	hazards.process(delta)
	_emit_gauges(delta)
	move_and_slide()

	# Post-move corrections run AFTER the slide so constraints have the last
	# word each tick — the solver can no longer re-stretch them.
	if state == State.SWING:
		tether.post_move(delta)

	# A climb ends when there is no wall left to hold.
	if state == State.CLIMB and climb_grace <= 0.0 and not is_on_wall():
		change_state(State.MOVE)
		spikes.reset_slip()

	rope.visible = state == State.SWING
	if rope.visible:
		rope.points = PackedVector2Array([Vector2.ZERO, rope.to_local(tether.anchor_point)])


func change_state(new_state: State) -> void:
	state = new_state


# -------------------------------------------------------------- failure ---

func _emit_gauges(delta: float) -> void:
	_gauge_emit += delta
	if _gauge_emit < GAUGE_EMIT_S:
		return
	_gauge_emit = 0.0
	EventBus.gauges_changed.emit({
		"heat": hazards.heat,
		"chill": hazards.chill,
		"radiation": hazards.radiation,
		# -1 = the O2 tool is not equipped, the HUD hides the bar.
		"o2": o2.o2 if has_tool(&"tool.o2") else -1.0,
	})


func fail(entry_id: StringName, reason: String) -> void:
	if mission_over:
		return
	mission_over = true
	BookOfBooks.add_note(entry_id, reason, {
		"heat": hazards.heat,
		"chill": hazards.chill,
		"radiation": hazards.radiation,
		"o2": o2.o2,
	})
	EventBus.mission_failed.emit(entry_id, reason)


# -------------------------------------------------------------- loadout ---

func total_mass_kg() -> float:
	var m := GameConstants.PLAYER_MASS_KG + GameConstants.SUIT_MASS_KG
	if has_tool(&"tool.jetpack"):
		m += TOOL_JETPACK.mass_kg + jetpack.propellant * GameConstants.JETPACK_PROPELLANT_KG
	return m


## Heavier loadout = slower walk, weaker jump.
func mass_factor() -> float:
	var base := GameConstants.PLAYER_MASS_KG + GameConstants.SUIT_MASS_KG
	return sqrt(base / total_mass_kg())


func has_tool(tool_id: StringName) -> bool:
	# Test-bench convenience: an empty loadout means everything is usable.
	# A real mission always fills GameState.loadout from the hub.
	if GameState.loadout.is_empty():
		return true
	return GameState.loadout.has(tool_id)


func _announce_equipped() -> void:
	if GameState.loadout.is_empty():
		for tool in [TOOL_JETPACK, TOOL_TETHER, TOOL_SPIKES, TOOL_O2]:
			EventBus.tool_equipped.emit(tool.tool_id)
	else:
		for tool_id in GameState.loadout:
			EventBus.tool_equipped.emit(tool_id)
