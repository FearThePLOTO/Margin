class_name PlayerMoveMechanic
extends PlayerMechanic
## MOVE state: walk accel/decel, moon gravity, buffered jumping.
## Celeste-style feel on top: variable jump height (release to cut), heavier
## falls, apex hang while jump is held, snappy ground stop and ceiling-corner
## correction. Also routes tool activation (tether fire, spikes deploy).

## True while the current upward motion came from a jump (so releasing jump
## only cuts real jumps, never jetpack thrust).
var _jump_cut_armed := false
## Set for one tick when a jump fires (the animation resolver plays takeoff).
var jumped_this_tick := false


func process(delta: float) -> void:
	jumped_this_tick = false
	var input_x := 0.0 if player.input_locked else Input.get_axis(&"move_left", &"move_right")
	if player.input_locked:
		player.jump_buffer = 0.0
	var speed := GameConstants.WALK_SPEED_PXS * player.mass_factor()
	var accel: float
	if player.is_on_floor():
		accel = GameConstants.GROUND_ACCEL_PXS if input_x != 0.0 else GameConstants.GROUND_DECEL_PXS
	else:
		accel = GameConstants.AIR_ACCEL_PXS
	player.velocity.x = move_toward(player.velocity.x, input_x * speed, accel * delta)
	player.velocity.y = minf(player.velocity.y + _gravity() * delta, GameConstants.TERMINAL_FALL_PXS)

	if player.is_on_floor():
		player.coyote = GameConstants.COYOTE_TIME_S
	else:
		player.coyote = maxf(0.0, player.coyote - delta)
	if player.jump_buffer > 0.0 and player.coyote > 0.0:
		player.velocity.y = -GameConstants.JUMP_SPEED_PXS * player.mass_factor()
		player.jump_buffer = 0.0
		player.coyote = 0.0
		_jump_cut_armed = true
		jumped_this_tick = true

	# Variable jump height: let go early for a short hop.
	if _jump_cut_armed:
		if player.velocity.y >= 0.0:
			_jump_cut_armed = false
		elif not Input.is_action_pressed(&"jump") or player.input_locked:
			player.velocity.y *= GameConstants.JUMP_CUT_MULT
			_jump_cut_armed = false

	_corner_correct(delta)
	if player.input_locked:
		return
	player.jetpack.process(delta)

	if Input.is_action_just_pressed(&"tether_fire") and player.has_tool(&"tool.tether"):
		player.tether.try_fire()
	elif Input.is_action_just_pressed(&"spikes_deploy") and player.has_tool(&"tool.spikes") and player.is_on_wall():
		player.spikes.enter_climb()


func _gravity() -> float:
	var g := GameConstants.MOON_GRAVITY_PXS
	if player.velocity.y > 0.0:
		return g * GameConstants.FALL_GRAVITY_MULT
	if absf(player.velocity.y) < GameConstants.APEX_HANG_PXS and Input.is_action_pressed(&"jump"):
		return g * GameConstants.APEX_GRAVITY_MULT
	return g


## Rising into a ceiling corner by a few pixels nudges the player sideways
## instead of killing the jump (Celeste's corner correction).
func _corner_correct(delta: float) -> void:
	if player.velocity.y >= 0.0:
		return
	var up := Vector2(0.0, player.velocity.y * delta)
	var xf := player.global_transform
	if not player.test_move(xf, up):
		return
	for i in range(1, GameConstants.CORNER_CORRECT_PX + 1):
		for dir: int in [-1, 1]:
			var side := Vector2(i * dir, 0.0)
			if not player.test_move(xf, side) and not player.test_move(xf.translated(side), up):
				player.global_position.x += i * dir
				return
