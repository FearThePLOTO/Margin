extends Area2D
## Cave mouth / doorway: walking in fades to black and moves the player to the
## `target` marker (e.g. the first cave room). If `requires` points at a
## cutscene trigger, the warp only works after that cutscene has played.

@export var target: NodePath
@export var requires: NodePath
@export var fade_s := 0.35

var _busy := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _busy or not body.is_in_group(&"player"):
		return
	var gate := get_node_or_null(requires)
	if gate and not gate.get("played"):
		return
	_busy = true
	EventBus.cutscene_started.emit()
	var layer := CanvasLayer.new()
	layer.layer = 20
	var black := ColorRect.new()
	black.color = Color(0, 0, 0, 0)
	black.size = Vector2(320, 180)
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(black)
	add_child(layer)
	var tw := create_tween()
	tw.tween_property(black, "color:a", 1.0, fade_s)
	await tw.finished
	var dest := get_node(target) as Node2D
	body.global_position = dest.global_position
	body.set("velocity", Vector2.ZERO)
	var cam := body.get_node_or_null(^"Camera2D") as Camera2D
	if cam:
		cam.reset_smoothing()
	await get_tree().create_timer(0.2).timeout
	var tw2 := create_tween()
	tw2.tween_property(black, "color:a", 0.0, fade_s)
	await tw2.finished
	layer.queue_free()
	EventBus.cutscene_ended.emit()
	_busy = false
