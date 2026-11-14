extends Area2D
## Level exit: the opening into the next room, with an "OUT ->" sign.
## Walking in saves deaths + scrolls to the Book of Books, fades out and shows
## the results screen. Works from main.tscn (EventBus.mission_completed) and
## when the level is played on its own (loads main.tscn, which reads
## GameState.pending_results).

const MAIN_SCENE := "res://src/core/main.tscn"

@export var level_id := "level_01"

var _done := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if _done or not body.is_in_group(&"player"):
		return
	_done = true
	var stats := {"level": level_id, "scrolls_total": get_tree().get_nodes_in_group(&"scroll").size()}
	BookOfBooks.record_level(level_id, GameState.total_deaths(), GameState.scrolls.size())
	GameState.pending_results = stats
	GameState.clear_run_save()   # level finished: nothing left to CONTINUE
	EventBus.cutscene_started.emit()
	var layer := CanvasLayer.new()
	layer.layer = 30
	var black := ColorRect.new()
	black.color = Color(0, 0, 0, 0)
	black.size = Vector2(320, 180)
	black.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.add_child(black)
	add_child(layer)
	var tw := create_tween()
	tw.tween_property(black, "color:a", 1.0, 0.6)
	await tw.finished
	var scene := get_tree().current_scene
	if scene and scene.scene_file_path == MAIN_SCENE:
		EventBus.mission_completed.emit(stats)
	else:
		get_tree().change_scene_to_file(MAIN_SCENE)
