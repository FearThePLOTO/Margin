class_name PlayerMoveMechanic
extends PlayerMechanic
## MOVE state: walk accel/decel, moon gravity, buffered jumping.
## Also routes tool activation (tether fire, spikes deploy) from the ground.

func process(delta: float) -> void:
	var input_x := Input.get_axis(&"move_left", &"move_right")
	var speed := GameConstants.WALK_SPEED_PXS * player.mass_factor()
	var accel := GameConstants.GROUND_ACCEL_PXS if player.is_on_floor() else GameConstants.AIR_ACCEL_PXS
	player.velocity.x = move_toward(player.velocity.x, input_x * speed, accel * delta)
	player.velocity.y = minf(player.velocity.y + GameConstants.MOON_GRAVITY_PXS * delta, GameConstants.TERMINAL_FALL_PXS)

	if player.is_on_floor():
		player.coyote = GameConstants.COYOTE_TIME_S
	else:
		player.coyote = maxf(0.0, player.coyote - delta)
	if player.jump_buffer > 0.0 and player.coyote > 0.0:
		player.velocity.y = -GameConstants.JUMP_SPEED_PXS * player.mass_factor()
		player.jump_buffer = 0.0
		player.coyote = 0.0

	player.jetpack.process(delta)

	if Input.is_action_just_pressed(&"tether_fire") and player.has_tool(&"tool.tether"):
		player.tether.try_fire()
	elif Input.is_action_just_pressed(&"spikes_deploy") and player.has_tool(&"tool.spikes") and player.is_on_wall():
		player.spikes.enter_climb()
