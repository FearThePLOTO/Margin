extends Area2D
## Level exit airlock. Opens and reports the mission as completed when the
## player walks in. Drag exit_door.tscn so its bottom sits on the floor.

@export var level_id: StringName = &"level_01"

var _done := false

@onready var _sprite: AnimatedSprite2D = $Sprite


func _ready() -> void:
	add_to_group(&"level_exit")
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _done or not body.is_in_group(&"player"):
		return
	_done = true
	_sprite.play(&"open")
	EventBus.mission_completed.emit({
		"level": level_id,
		"scrolls_total": get_tree().get_nodes_in_group(&"scroll").size(),
	})
