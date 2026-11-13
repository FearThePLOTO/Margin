class_name PlayerTetherMechanic
extends PlayerMechanic
## Tether: anchor search + attach, hand-computed taut-rope pendulum swing
## (no joint node, so the rope never snaps the physics solver and stays
## kid-forgiving), reel in/out, and release/fling.

var anchor_point := Vector2.ZERO

var _rope_len := 0.0


func try_fire() -> void:
	# A slack arrest above this speed would spike tension; the forgiving
	# counter is that the hook skids off instead of snapping.
	if player.velocity.length() > GameConstants.TETHER_SLIP_SPEED_PXS:
		return
	var best: Node2D = null
	var best_d := GameConstants.TETHER_MAX_ROPE_PXS
	for node in player.get_tree().get_nodes_in_group(&"tether_anchor"):
		var anchor := node as Node2D
		if anchor == null:
			continue
		# Anchors well below the player are not swings; skip them.
		if anchor.global_position.y > player.global_position.y + 32.0:
			continue
		var d := player.global_position.distance_to(anchor.global_position)
		if d < best_d:
			best_d = d
			best = anchor
	if best == null:
		return
	player.change_state(Player.State.SWING)
	anchor_point = best.global_position
	_rope_len = maxf(GameConstants.TETHER_MIN_ROPE_PXS, best_d)
	player.velocity = player.velocity.limit_length(GameConstants.TETHER_SLIP_SPEED_PXS)
	# Attach is a discrete event; don't let the camera lerp across the snap.
	player.camera.reset_smoothing()
	EventBus.tool_used.emit(&"tool.tether")


func process(delta: float) -> void:
	player.velocity.y += GameConstants.MOON_GRAVITY_PXS * delta

	# Kid-friendly pump: small tangential push with the move keys.
	var input_x := Input.get_axis(&"move_left", &"move_right")
	if input_x != 0.0:
		var to_anchor := anchor_point - player.global_position
		if to_anchor.length() > 1.0:
			var tangent := Vector2(-to_anchor.y, to_anchor.x).normalized()
			player.velocity += tangent * input_x * GameConstants.SWING_PUMP_ACCEL_PXS * delta

	# Reel in / out with up / down.
	var reel := Input.get_axis(&"move_down", &"move_up")
	if reel != 0.0:
		_rope_len = clampf(
			_rope_len - reel * GameConstants.TETHER_REEL_SPEED_PXS * delta,
			GameConstants.TETHER_MIN_ROPE_PXS, GameConstants.TETHER_MAX_ROPE_PXS)

	# Hold-to-swing: releasing the key detaches; jump detaches with a small
	# upward pop (fling).
	if Input.is_action_just_released(&"tether_fire"):
		player.change_state(Player.State.MOVE)
		player.coyote = 0.0
	elif player.jump_buffer > 0.0:
		player.jump_buffer = 0.0
		player.velocity.y = minf(player.velocity.y, -GameConstants.JUMP_SPEED_PXS * 0.6)
		player.change_state(Player.State.MOVE)
		player.coyote = 0.0


## Runs after move_and_slide(): projects onto the rope circle and strips
## radial velocity, so the constraint is the last word each tick instead of
## being overruled by the slide (which used to re-stretch the rope).
func post_move(_delta: float) -> void:
	var offset := player.global_position - anchor_point
	var dist := offset.length()
	if dist > _rope_len:
		var n := offset / dist
		player.global_position = anchor_point + n * _rope_len
		var radial := player.velocity.dot(n)
		if radial > 0.0:
			player.velocity -= n * radial
