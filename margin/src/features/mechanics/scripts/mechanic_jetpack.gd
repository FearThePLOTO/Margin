class_name PlayerJetpackMechanic
extends PlayerMechanic
## Jetpack: thrust vectoring + the propellant gauge.
## Thrust is limited and the tank drains at a constant rate over burn_time_s;
## draining makes the (lighter) system accelerate faster — the trade-off made
## visible. Masses are relative weights, so no unit conversion is involved.

const TOOL_JETPACK := preload("res://src/features/mechanics/resources/tool_jetpack.tres")

var propellant: float = 1.0  # tank fill, 0..1

var _thrusting := false


func process(delta: float) -> void:
	if not player.has_tool(&"tool.jetpack") or propellant <= 0.0:
		_thrusting = false
		return
	if not Input.is_action_pressed(&"jetpack_thrust"):
		_thrusting = false
		return
	var dir := Input.get_vector(&"move_left", &"move_right", &"move_up", &"move_down")
	if dir == Vector2.ZERO:
		dir = Vector2.UP
	var thrust_accel := TOOL_JETPACK.thrust_pxs / player.total_mass_kg()
	player.velocity += dir * thrust_accel * delta
	propellant = maxf(0.0, propellant - delta / TOOL_JETPACK.burn_time_s)
	if not _thrusting:
		_thrusting = true
		EventBus.tool_used.emit(&"tool.jetpack")
