extends Control
## In-game pause screen (ESC). The frozen game turns blue (shaders/pause_blue),
## and a big kid-readable list offers:
##   RESUME / RETRY CHECKPOINT / RESTART LEVEL / BOOK OF BOOKS / OPTIONS / MAIN MENU
## RESTART LEVEL and MAIN MENU ask "are you sure?" first.
## Hosted by mission_overlay (which owns the Book of Books screen).

signal resumed
signal book_requested

const MAIN_SCENE := "res://src/core/main.tscn"
const ITEMS := ["RESUME", "RETRY CHECKPOINT", "RESTART LEVEL", "BOOK OF BOOKS", "OPTIONS", "MAIN MENU"]
enum { RESUME, RETRY, RESTART, BOOK, OPTIONS, MENU }

@onready var _tint: ColorRect = %Tint
@onready var _content: Control = %Content
@onready var _level: Label = %LevelName
@onready var _stats: Label = %Stats
@onready var _question: Label = %Question
@onready var _menu: PixelMenu = %PauseList
@onready var _options = %Options  # settings_panel.gd

var _confirming := -1


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	_menu.active = false
	_menu.chosen.connect(_on_chosen)
	_options.closed.connect(_on_options_closed)


func open() -> void:
	get_tree().paused = true
	var lvl := BookOfBooks.get_level(GameState.level_id)
	_level.text = "LEVEL %d : %s" % [int(lvl.get("number", 1)), str(lvl.get("name", ""))] if not lvl.is_empty() else ""
	var total := get_tree().get_nodes_in_group(&"scroll").size()
	_stats.text = "DEATHS %d     SCROLLS %d / %d" % [GameState.total_deaths(), GameState.scrolls.size(), total]
	_show_list(RESUME)
	show()
	var mat := _tint.material as ShaderMaterial
	mat.set_shader_parameter(&"amount", 0.0)
	create_tween().tween_method(func(v: float) -> void: mat.set_shader_parameter(&"amount", v), 0.0, 1.0, 0.18)
	_content.modulate.a = 0.0
	_content.position.y = -6.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_content, "modulate:a", 1.0, 0.18)
	tw.tween_property(_content, "position:y", 0.0, 0.18).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


## Shows the pause list again (after the Book of Books closes).
func reopen() -> void:
	show()
	_show_list(BOOK)


func close() -> void:
	_menu.active = false
	_options.hide()
	hide()
	get_tree().paused = false
	resumed.emit()


func _show_list(select: int) -> void:
	_confirming = -1
	_question.hide()
	_menu.options = PackedStringArray(ITEMS)
	_menu.selected = select
	_menu.active = true
	_menu.queue_redraw()


func _ask(which: int, question: String, yes: String) -> void:
	_confirming = which
	_question.text = question
	_question.show()
	_menu.options = PackedStringArray([yes, "NO"])
	_menu.selected = 1
	_menu.queue_redraw()


func _on_chosen(i: int) -> void:
	if _confirming >= 0:
		if i == 1:
			_show_list(_confirming)
			return
		var which := _confirming
		close()
		if which == RESTART:
			_restart()
		else:
			EventBus.return_to_menu_requested.emit()
		return
	match i:
		RESUME:
			close()
		RETRY:
			close()
			EventBus.hazard_kill.emit(&"retry")   # back to the last checkpoint
		RESTART:
			_ask(RESTART, "RESTART FROM THE BEGINNING?", "YES, RESTART")
		BOOK:
			_menu.active = false
			hide()
			book_requested.emit()
		OPTIONS:
			_menu.active = false
			_content.hide()
			_options.open()
		MENU:
			_ask(MENU, "QUIT TO THE MAIN MENU?", "YES, QUIT")


func _restart() -> void:
	var scene := get_tree().current_scene
	if scene and scene.scene_file_path == MAIN_SCENE:
		EventBus.restart_level_requested.emit()
	else:  # level played on its own (F6)
		GameState.reset_mission()
		get_tree().reload_current_scene()


func _on_options_closed() -> void:
	_content.show()
	_show_list(OPTIONS)


func _input(event: InputEvent) -> void:
	if not visible or _options.visible:
		return
	if event.is_action_pressed(&"ui_cancel"):
		if _confirming >= 0:
			_show_list(_confirming)
		else:
			close()
		get_viewport().set_input_as_handled()
