class_name PlayerDeathMechanic
extends PlayerMechanic
## Celeste-style procedural death: on a kill hazard or falling out of bounds
## the sprite hides and controls lock for a 0.08 s hit-stop, then a ring of 8
## orbs bursts from the player's center (Celeste DeathEffect math: cubic
## ease-out expansion, rotating ring, hair/white flicker, 0.834 s life) with a
## decaying screen shake. 0.3 s in, a fast black wipe crosses the screen, the
## player is reset to the checkpoint under cover, and control returns when
## the wipe clears.
##
## Touch-kill zones signal over EventBus (hazard_kill) — the zone never
## references the player directly. Slow gauge accrual (heat/chill/radiation)
## keeps using Player.fail() — that is the mission-failure loop, not a death.

const ORB_COUNT := 8
## Constants below mirror Celeste's DeathEffect.cs (reverse-engineered source):
## 0.834 s life, radius eases out to 24 px with cubic ease-out while the ring
## rotates a quarter turn, blobs grow to full size over the first half then
## shrink to zero, and every ~0.1 s the blob color flips hair-color <-> white.
const ORB_LIFE_S := 0.834
const ORB_SPREAD_PXS := 24.0
## Suit blue sampled from the sprite sheet torso — stands in for "hair color"
## (the astronaut has none).
const ORB_COLOR := Color(0.0, 0.19, 0.56)
const WIPE_SIZE := Vector2(320, 180)

var dying := false
## Reset point, captured at spawn; rooms move it via EventBus.checkpoint_reached.
var checkpoint := Vector2.ZERO
## O2 supply when the checkpoint was set — restored on respawn so a death never
## costs more air than the room itself did.
var checkpoint_o2 := 1.0

var _camera: Camera2D
var _sprite: AnimatedSprite2D
var _wipe_rect: ColorRect
var _shake_phase := 0.0


func _init(p: Player) -> void:
	super(p)
	checkpoint = p.global_position
	_camera = p.get_node(^"Camera2D")
	_sprite = p.get_node(^"Sprite2D")
	EventBus.hazard_kill.connect(_on_hazard_kill)
	EventBus.checkpoint_reached.connect(_on_checkpoint_reached)


func _on_checkpoint_reached(pos: Vector2) -> void:
	checkpoint = pos
	checkpoint_o2 = player.o2.o2 if player.o2 else 1.0


func process(_delta: float) -> void:
	if dying:
		return
	if player.global_position.y > player.kill_y:
		die()


func _on_hazard_kill(zone_id: StringName) -> void:
	die(zone_id)


func die(cause: StringName = &"fall") -> void:
	if dying or player.mission_over:
		return
	dying = true
	GameState.log_death(cause)
	EventBus.player_died.emit()
	_sprite.visible = false
	player.set_physics_process(false)
	player.velocity = Vector2.ZERO

	# (1) hit-stop: real-time delay so the freeze ends even at 0.05x scale.
	Engine.time_scale = 0.05
	await player.get_tree().create_timer(0.08, true, false, true).timeout
	Engine.time_scale = 1.0

	# (2) orb burst + shake (time is restored, tweens run at full speed).
	_burst_orbs(player.global_position)
	_shake()

	# (3) short beat, then the wipe carries the respawn.
	await player.get_tree().create_timer(0.3).timeout
	await _wipe_respawn()


func _burst_orbs(at: Vector2) -> void:
	var burst := DeathBurst.new()
	burst.position = at
	player.get_parent().add_child(burst)


## Decaying trauma shake on the camera OFFSET (never the body).
func _shake() -> void:
	_shake_phase = 0.0
	var tw := _camera.create_tween()
	tw.tween_method(_shake_step, 1.0, 0.0, 0.35)
	tw.tween_callback(func() -> void: _camera.offset = Vector2.ZERO)


func _shake_step(amp: float) -> void:
	_shake_phase += 0.8
	_camera.offset = Vector2(sin(_shake_phase * 1.3), sin(_shake_phase * 1.9)) * 7.0 * amp


func _wipe_respawn() -> void:
	if _wipe_rect == null:
		var layer := CanvasLayer.new()
		layer.layer = 10
		_wipe_rect = ColorRect.new()
		_wipe_rect.color = Color.BLACK
		_wipe_rect.size = WIPE_SIZE
		_wipe_rect.position = Vector2(-WIPE_SIZE.x, 0)
		_wipe_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.add_child(_wipe_rect)
		player.add_child(layer)

	var tw_in := _wipe_rect.create_tween()
	tw_in.tween_property(_wipe_rect, "position:x", 0.0, 0.12) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tw_in.finished

	# Respawn under cover.
	player.global_position = checkpoint
	player.velocity = Vector2.ZERO
	player.change_state(Player.State.MOVE)
	player.hazards.heat = 0.0
	player.hazards.chill = 0.0
	player.hazards.radiation = 0.0
	var floor_o2 := GameConstants.RESPAWN_O2_FLOOR if player.fail_is_death else 0.0
	player.o2.o2 = maxf(checkpoint_o2, floor_o2)
	_camera.reset_smoothing()
	_sprite.visible = true

	var tw_out := _wipe_rect.create_tween()
	tw_out.tween_property(_wipe_rect, "position:x", WIPE_SIZE.x, 0.12) \
			.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw_out.finished
	_wipe_rect.position.x = -WIPE_SIZE.x

	player.set_physics_process(true)
	dying = false
	EventBus.player_respawned.emit()


## One node renders the whole Celeste-style death ring: 8 blobs drawn per
## frame with the exact DeathEffect math, plus randomized and space touches —
## a random ring rotation and per-blob jitter each run, tiny star-dust specks
## drifting out slower than the ring, and a soft vacuum-fade glow.
class DeathBurst extends Node2D:
	## Suit color stands in for the player's "hair color" (astronaut has none).
	var suit_color := Color(0.0, 0.19, 0.56)
	var blob_radius := 3.0
	var _t := 0.0
	var _ring_offset := 0.0
	var _jitters: Array[Vector2] = []
	var _size_jitter: Array[float] = []
	var _speck_dirs: Array[Vector2] = []


	func _ready() -> void:
		_ring_offset = randf() * TAU
		for i in ORB_COUNT:
			_jitters.append(Vector2(randf_range(-3.0, 3.0), randf_range(-3.0, 3.0)))
			_size_jitter.append(randf_range(0.8, 1.2))
			_speck_dirs.append(Vector2.RIGHT.rotated(randf() * TAU))


	func _process(delta: float) -> void:
		_t += delta / ORB_LIFE_S
		if _t >= 1.0:
			queue_free()
			return
		queue_redraw()


	static func _cube_out(x: float) -> float:
		return 1.0 - pow(1.0 - x, 3.0)


	func _draw() -> void:
		var e := clampf(_t, 0.0, 1.0)
		var radius := _cube_out(e) * ORB_SPREAD_PXS
		# Celeste size curve: grow 0.5 -> 1.0 over the first half, then
		# cubic-ease down to 0.
		var blob_scale := 0.5 + e if e < 0.5 else _cube_out(1.0 - (e - 0.5) * 2.0)
		# Hair color <-> white flicker every 0.1 s (floor(ease*10) % 2).
		var col := suit_color if int(floor(e * 10.0)) % 2 == 0 else Color.WHITE
		var alpha := 1.0 - e

		# Vacuum-fade glow halo behind the ring.
		draw_circle(Vector2.ZERO, radius + 6.0, Color(suit_color, 0.10 * alpha))

		# Star-dust: slow random specks drifting out, fading to nothing.
		for dir: Vector2 in _speck_dirs:
			var speck_alpha := alpha * 0.7
			draw_circle(dir * radius * 0.5, 0.7, Color(0.75, 0.82, 1.0, speck_alpha))

		# The 8-blob ring, rotating a quarter turn over the effect's life.
		for i in ORB_COUNT:
			var ang := (float(i) / float(ORB_COUNT) + _ring_offset / TAU + e * 0.25) * TAU
			var pos := Vector2.RIGHT.rotated(ang) * radius + _jitters[i]
			var r := blob_radius * blob_scale * _size_jitter[i]
			# 1 px black outline, Celeste-style (4 offset black draws).
			for off: Vector2 in [Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN]:
				draw_circle(pos + off, r, Color.BLACK)
			draw_circle(pos, r, col)
