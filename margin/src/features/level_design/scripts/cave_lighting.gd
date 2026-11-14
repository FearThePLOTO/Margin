extends CanvasModulate
## Darkens the world inside any `Cave` hazard zone (your headlamp and glowing
## lava are what you see by) and returns to daylight outside.

@export var cave_color := Color(0.16, 0.12, 0.2)
@export var day_color := Color(1, 1, 1)
@export var fade_s := 0.6


func _ready() -> void:
	color = day_color
	EventBus.hazard_entered.connect(_on_entered)
	EventBus.hazard_exited.connect(_on_exited)


func _on_entered(zone_id: StringName) -> void:
	if zone_id == &"Cave":
		_fade(cave_color)


func _on_exited(zone_id: StringName) -> void:
	if zone_id == &"Cave":
		_fade(day_color)


func _fade(c: Color) -> void:
	create_tween().tween_property(self, "color", c, fade_s)
