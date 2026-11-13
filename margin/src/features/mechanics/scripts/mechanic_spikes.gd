class_name PlayerSpikesMechanic
extends PlayerMechanic
## Climbing spikes: climb/slide, wall press, regolith slip weakness,
## lean-off detach and wall jump.

var _slip_timer := 0.0  # slip timer inside LooseRegolith zones
var _last_wall_normal := Vector2.ZERO  # cached; get_wall_normal() is dead on attach


func enter_climb() -> void:
	player.change_state(Player.State.CLIMB)
	_slip_timer = 0.0
	_last_wall_normal = Vector2.ZERO
	player.velocity = player.velocity.limit_length(20.0)
	EventBus.tool_used.emit(&"tool.spikes")


func reset_slip() -> void:
	_slip_timer = 0.0


func detach(knocked: bool = false) -> void:
	player.change_state(Player.State.MOVE)
	_slip_timer = 0.0
	_last_wall_normal = Vector2.ZERO
	if knocked and player.is_on_wall():
		player.velocity = player.get_wall_normal() * 40.0 + Vector2(0, 60.0)


func process(delta: float) -> void:
	# get_wall_normal() is only valid after a move_and_slide() collision, so
	# the first ticks of a climb would read Vector2.ZERO. Cache the last
	# known contact instead.
	if player.is_on_wall():
		_last_wall_normal = player.get_wall_normal()
	var wall_normal := _last_wall_normal
	var into_wall := -wall_normal

	# Climb with up/down; no input = slow controlled slide (weakness trade-off).
	var up_down := Input.get_axis(&"move_down", &"move_up")
	var climb_speed := GameConstants.SPIKES_CLIMB_SPEED_PXS
	if up_down != 0.0:
		player.velocity.y = move_toward(player.velocity.y, -up_down * climb_speed, climb_speed * 8.0 * delta)
	else:
		player.velocity.y = move_toward(player.velocity.y, GameConstants.SPIKES_SLIDE_SPEED_PXS, climb_speed * 4.0 * delta)
	player.velocity.x = into_wall.x * 20.0  # keep pressed against the wall

	# Weakness: "very low pull-out resistance in loose regolith" — inside a
	# LooseRegolith zone the pitons work loose.
	if player.hazards.is_in_zone(&"LooseRegolith"):
		_slip_timer += delta
		if _slip_timer >= GameConstants.SPIKES_REGOLITH_SLIP_S:
			detach(true)
			return
	else:
		_slip_timer = 0.0

	# Leaning away from the wall drops you off.
	var input_x := Input.get_axis(&"move_left", &"move_right")
	if input_x != 0.0 and signf(input_x) == signf(wall_normal.x):
		detach()
		return

	# Wall jump resets fall velocity — "drive spikes into walls during a
	# descent to reset fall velocity".
	if player.jump_buffer > 0.0:
		player.jump_buffer = 0.0
		player.velocity = wall_normal * GameConstants.WALL_JUMP_X_PXS \
				+ Vector2(0.0, -GameConstants.JUMP_SPEED_PXS * 0.8)
		player.change_state(Player.State.MOVE)
		player.climb_grace = 0.15
		return

	if Input.is_action_just_pressed(&"spikes_deploy"):
		detach()
