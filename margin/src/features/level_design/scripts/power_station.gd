extends Area2D
## Power Station (Junior Astronaut trade-off). The first time the player walks
## in, the station charges ONE NEW battery cell: the player picks which system
## gets it (AIR / SHIELD / LIGHT, max 3 each), then the normal Power Plan opens
## to move every cell around. Afterwards, stand here and press UP to re-plan.
## (A run starts with 3 cells; GameState.stations_charged remembers which
## stations already paid out, so CONTINUE never gives a cell twice.)
## `forecast` is shown as a hint so kids can plan for what is ahead.

@export var station_name := "Station"
@export_multiline var forecast := "Ahead: a long, dark cave."

var _inside := false
var _used := false


func _ready() -> void:
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)


func _on_exit(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		_inside = false


func _on_enter(body: Node2D) -> void:
	if not body.is_in_group(&"player"):
		return
	_inside = true
	if not _used:
		_used = true
		EventBus.hint_requested.emit(forecast)
		EventBus.power_plan_requested.emit(StringName(station_name))
	else:
		EventBus.hint_requested.emit("UP: change power plan")


func _unhandled_input(event: InputEvent) -> void:
	if _inside and event.is_action_pressed(&"move_up"):
		EventBus.power_plan_requested.emit(StringName(station_name))
