extends Control
## Entry scene: drives the game flow.
##   main menu (core/ui/main_menu.tscn: storm title card, then the choices)
##     -> START NEW GAME / CONTINUE (last checkpoint) -> Level 1
##     -> "OUT ->" exit (EventBus.mission_completed) -> results screen
##     -> back to the menu
##   Pause menu RESTART LEVEL -> EventBus.restart_level_requested -> fresh level
## Screens and levels are swapped as children of this node.

const MAIN_MENU := preload("res://src/core/ui/main_menu.tscn")
const LEVEL_1 := preload("res://src/core/game/level_01/level_01.tscn")
const REPORT := preload("res://src/core/ui/results_screen.tscn")

var _current: Node


func _ready() -> void:
	EventBus.mission_completed.connect(_on_mission_completed)
	EventBus.mission_failed.connect(_on_mission_failed)
	EventBus.return_to_menu_requested.connect(_show_menu, CONNECT_DEFERRED)
	EventBus.restart_level_requested.connect(_start_mission.bind(false), CONNECT_DEFERRED)
	# A level played on its own (F6) hands its results here when it ends.
	if not GameState.pending_results.is_empty():
		var stats := GameState.pending_results
		GameState.pending_results = {}
		_show_report(stats)
		return
	_show_menu()


func _swap(node: Node) -> void:
	get_tree().paused = false
	if _current:
		# Leave the tree NOW: a queued-but-present old level would still answer
		# "first node in group player/scroll" for the new level (lander hid the
		# old Max, the HUD counted 6 scrolls).
		remove_child(_current)
		_current.queue_free()
	_current = node
	add_child(node)


func _show_menu() -> void:
	GameState.phase = GameState.Phase.HUB
	var menu: Node = MAIN_MENU.instantiate()
	menu.connect(&"new_game_requested", _new_game)
	menu.connect(&"continue_requested", _start_mission.bind(true))
	_swap(menu)


## START NEW GAME: everything starts over (scrolls, book chapters, deaths).
func _new_game() -> void:
	BookOfBooks.reset_progress()
	_start_mission(false)


## `resume`: start at the saved checkpoint (CONTINUE) instead of the landing.
func _start_mission(resume: bool) -> void:
	GameState.reset_mission()
	SpaceWeather.new_mission()
	GameState.phase = GameState.Phase.MISSION
	var at := GameState.load_run_save() if resume else Vector2.INF
	if not resume:
		GameState.clear_run_save()
	GameState.resume_point = at   # read by the lander / autostart cutscenes in _ready
	_swap(LEVEL_1.instantiate())
	GameState.resume_point = Vector2.INF
	if at != Vector2.INF:
		var player = get_tree().get_first_node_in_group(&"player")  # player.gd
		if player:
			player.global_position = at
			player.death.checkpoint = at
			var cam := player.get_node_or_null(^"Camera2D") as Camera2D
			if cam:
				cam.reset_smoothing.call_deferred()


func _on_mission_completed(stats: Dictionary) -> void:
	GameState.pending_results = {}
	await get_tree().create_timer(0.8).timeout
	_show_report(stats)


## Non-training levels can still fail outright; show the same report.
func _on_mission_failed(_note_id: StringName, _reason: String) -> void:
	await get_tree().create_timer(1.5).timeout
	_show_report({})


func _show_report(stats: Dictionary) -> void:
	GameState.phase = GameState.Phase.DEBRIEF
	var report: Node = REPORT.instantiate()
	report.connect(&"back_requested", _show_menu)
	_swap(report)
	report.call(&"open", stats)
