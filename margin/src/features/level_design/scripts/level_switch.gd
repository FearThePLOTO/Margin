extends Area2D
## One-shot level switch: turns on a target node's collision and visibility.
## A level-design prop only (the sketch's "switch opens a platform in the
## high wall"), not a resource or gauge system.

@export var target_path: NodePath

var _used := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _used or not body.is_in_group(&"player"):
		return
	var target := get_node_or_null(target_path)
	if target == null:
		push_warning("Switch %s has no target" % name)
		return
	_used = true
	modulate = Color(0.6, 1.0, 0.6)
	target.visible = true
	for shape in target.find_children("*", "CollisionShape2D", true, false):
		shape.set_deferred("disabled", false)
