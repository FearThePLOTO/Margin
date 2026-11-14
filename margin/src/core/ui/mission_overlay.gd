extends CanvasLayer
## In-mission overlay (drop mission_overlay.tscn into any level). Owns:
##  - bottom HUD: AIR + RAD (left), power pips (right), storm + scrolls (centre)
##  - cinematic letterbox bars during cutscenes (HUD fades out)
##  - the Conversation Module DialogueBox, driven by EventBus.dialogue_requested
##  - the Power Plan screen (split 3 suit battery cells: AIR / SHIELD / LIGHT)
##  - Book of Books scroll notification + the ESC pause screen (pause_menu.tscn)
## Talks only through EventBus + GameState/SpaceWeather (feature boundary).

const ICONS := preload("res://src/assets/char/ui_icons.png")
const SYSTEMS := ["o2", "shield", "light"]  # String keys, same as GameState.power_plan
const NAMES := {"o2": "AIR", "shield": "SHIELD", "light": "LIGHT"}
const EFFECTS := {
	"o2": ["Runs out fast!", "Normal air", "Lasts longer", "Lasts longest"],
	"shield": ["No protection!", "Some shield", "Strong shield", "Max shield"],
	"light": ["Dark! No scans", "Small lamp", "Big lamp", "Huge lamp"],
}
const BAR_H := 14.0

var _plan := {}
var _row := 0
var _station := &""
var _cell_on: AtlasTexture
var _cell_off: AtlasTexture
var _cinematic := 0
## Step 1 at a station visited for the first time: place its NEW cell.
var _bonus := false

@onready var _hud: Control = %Hud
@onready var _air_bar: ProgressBar = %AirBar
@onready var _rad_bar: ProgressBar = %RadBar
@onready var _storm_label: Label = %StormLabel
@onready var _pips: Array[HBoxContainer] = [%PipsO2, %PipsShield, %PipsLight]
@onready var _samples_label: Label = %SamplesLabel
@onready var _bar_top: ColorRect = %BarTop
@onready var _bar_bottom: ColorRect = %BarBottom
@onready var _dialogue = %DialogueBox  # dialogue_box.gd
@onready var _plan_panel: Control = %PowerPlan
@onready var _plan_title: Label = %PlanTitle
@onready var _plan_storm: Label = %PlanStorm
@onready var _plan_free: Label = %PlanFree
@onready var _plan_explain: Label = %Explain
@onready var _plan_rows: Array[HBoxContainer] = [%RowO2, %RowShield, %RowLight]
@onready var _confirm: Button = %Confirm
@onready var _toast: Control = %Toast
@onready var _toast_title: Label = %ToastTitle
@onready var _pause = %PauseMenu  # pause_menu.gd
@onready var _book = %BookScreen  # book_screen.gd
@onready var _hint: Label = %Hint
@onready var _sfx: AudioStreamPlayer = %Sfx


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_sfx.bus = &"SFX"   # set in code: the export strips the scene's bus value
	_cell_on = _icon(6)
	_cell_off = _icon(7)
	_plan_panel.hide()
	_toast.hide()
	_hint.hide()
	_bar_top.offset_bottom = 0.0
	_bar_bottom.offset_top = 0.0
	EventBus.dialogue_requested.connect(_on_dialogue_requested)
	_dialogue.dialogue_finished.connect(_on_dialogue_finished)
	_dialogue.line_started.connect(func(who: String, sfx: bool) -> void: EventBus.dialogue_line_started.emit(who, sfx))
	EventBus.power_plan_requested.connect(_open_plan)
	EventBus.scroll_collected.connect(_show_card)
	_pause.book_requested.connect(_open_book)
	_book.closed.connect(_on_book_closed)
	_pause.hide()
	EventBus.space_weather_ready.connect(func(_i: Dictionary) -> void: _refresh_hud())
	EventBus.power_plan_changed.connect(func(_p: Dictionary) -> void: _refresh_hud())
	EventBus.gauges_changed.connect(_on_gauges)
	EventBus.hint_requested.connect(_show_hint)
	for i in _plan_rows.size():
		_plan_rows[i].get_node(^"Minus").pressed.connect(_change.bind(i, -1))
		_plan_rows[i].get_node(^"Plus").pressed.connect(_change.bind(i, 1))
	_confirm.pressed.connect(_confirm_plan)
	_refresh_hud.call_deferred()


func _icon(i: int) -> AtlasTexture:
	var t := AtlasTexture.new()
	t.atlas = ICONS
	t.region = Rect2(i * 8, 0, 8, 8)
	return t


func _set_pips(box: HBoxContainer, n: int) -> void:
	for j in box.get_child_count():
		(box.get_child(j) as TextureRect).texture = _cell_on if j < n else _cell_off


# ------------------------------------------------------- cutscene look ---

func _cinema(on: bool) -> void:
	_cinematic += 1 if on else -1
	_cinematic = maxi(_cinematic, 0)
	var show_bars := _cinematic > 0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_bar_top, "offset_bottom", BAR_H if show_bars else 0.0, 0.3)
	tw.tween_property(_bar_bottom, "offset_top", -BAR_H if show_bars else 0.0, 0.3)
	tw.tween_property(_hud, "modulate:a", 0.0 if show_bars else 1.0, 0.25)


func _on_dialogue_requested(sequence: Resource) -> void:
	EventBus.cutscene_started.emit()
	_cinema(true)
	_dialogue.start_dialogue(sequence as DialogueSequence)


func _on_dialogue_finished() -> void:
	_cinema(false)
	EventBus.dialogue_finished.emit()
	EventBus.cutscene_ended.emit()


# ----------------------------------------------------------- power plan ---

func _open_plan(station_id: StringName) -> void:
	_station = station_id
	_plan = GameState.power_plan.duplicate()
	_row = 0
	_bonus = not GameState.stations_charged.has(String(station_id)) and _has_room()
	_plan_storm.text = "STORM: %s.  %s" % [SpaceWeather.info.get("level", "?"), SpaceWeather.source_line()]
	_plan_panel.show()
	get_tree().paused = true
	EventBus.cutscene_started.emit()
	_refresh_plan()


func _free_cells() -> int:
	var used := 0
	for k: String in SYSTEMS:
		used += int(_plan[k])
	return GameState.power_cells - used


func _has_room() -> bool:
	for k: String in SYSTEMS:
		if int(_plan[k]) < GameState.MAX_PER_SYSTEM:
			return true
	return false


func _change(row: int, delta: int) -> void:
	_row = row
	if _bonus:
		if delta > 0:
			_add_new_cell(row)
		_refresh_plan()
		return
	var key: String = SYSTEMS[row]
	var v := int(_plan[key]) + delta
	if v >= 0 and v <= GameState.MAX_PER_SYSTEM and not (delta > 0 and _free_cells() <= 0):
		_plan[key] = v
	_refresh_plan()


## Step 1 -> 2: the station's new cell goes into `row`, then the normal plan.
func _add_new_cell(row: int) -> void:
	var key: String = SYSTEMS[row]
	if int(_plan[key]) >= GameState.MAX_PER_SYSTEM:
		return
	_plan[key] = int(_plan[key]) + 1
	GameState.power_cells += 1
	GameState.stations_charged.append(String(_station))
	_bonus = false
	_play(preload("res://src/features/audio/sfx/station.wav"))
	_refresh_plan()


func _refresh_plan() -> void:
	var free := _free_cells()
	if _bonus:
		_plan_title.text = "NEW POWER CELL!"
		_plan_explain.text = "Pick where the new cell goes!"
		_plan_free.text = "UP/DOWN: PICK   ENTER: ADD IT"
	else:
		_plan_title.text = "POWER PLAN: " + String(_station).to_upper()
		_plan_explain.text = "%d cells. Move them around!" % GameState.power_cells
		_plan_free.text = "CELLS LEFT: %d" % free if free > 0 else "ALL CELLS PLACED!"
	for i in _plan_rows.size():
		var key: String = SYSTEMS[i]
		var n := int(_plan[key])
		var row := _plan_rows[i]
		var name_label := row.get_node(^"Name") as Label
		name_label.text = NAMES[key]
		name_label.modulate = Color(1, 0.75, 0.3) if i == _row else Color.WHITE
		_set_pips(row.get_node(^"Pips") as HBoxContainer, n)
		var effect := EFFECTS[key][n] as String
		if _bonus and i == _row and n < GameState.MAX_PER_SYSTEM:
			effect = "+1: " + EFFECTS[key][n + 1]
		(row.get_node(^"Effect") as Label).text = effect
		(row.get_node(^"Minus") as Button).disabled = _bonus or n == 0
		(row.get_node(^"Plus") as Button).disabled = n >= GameState.MAX_PER_SYSTEM or (not _bonus and free <= 0)
	_confirm.disabled = _bonus or free != 0


func _confirm_plan() -> void:
	if _free_cells() != 0:
		return
	GameState.power_plan = _plan.duplicate()
	GameState.plan_history.append({
		"station": String(_station), "plan": _plan.duplicate(),
		"storm": SpaceWeather.info.get("level", "?"),
	})
	_plan_panel.hide()
	get_tree().paused = false
	_play(preload("res://src/features/audio/sfx/station.wav"))
	EventBus.power_plan_changed.emit(GameState.power_plan)
	EventBus.cutscene_ended.emit()


# --------------------------------------------------- scroll notification ---

var _toast_chapter := ""
var _toast_tween: Tween
var _book_from_pause := false


## Top-right notification. The game keeps running; B opens the book now.
func _show_card(chapter: Dictionary) -> void:
	_toast_chapter = str(chapter.get("id", ""))
	_toast_title.text = str(chapter.get("title", ""))
	_play(preload("res://src/features/audio/sfx/sample.wav"))
	_refresh_hud()
	_toast.show()
	_toast.modulate.a = 0.0
	if _toast_tween:
		_toast_tween.kill()
	_toast_tween = create_tween()
	_toast_tween.tween_property(_toast, "modulate:a", 1.0, 0.25)
	_toast_tween.tween_interval(4.5)
	_toast_tween.tween_property(_toast, "modulate:a", 0.0, 0.4)
	_toast_tween.tween_callback(_toast.hide)


func _open_book_now() -> void:
	get_tree().paused = true
	_book_from_pause = false
	_book.open(GameState.level_id, _toast_chapter if _toast.visible else "")
	_toast.hide()


# ------------------------------------------------------------------ hud ---

func _on_gauges(g: Dictionary) -> void:
	var o2: float = g.get("o2", -1.0)
	(_air_bar.get_parent() as CanvasItem).visible = o2 >= 0.0
	_air_bar.value = maxf(o2, 0.0) * 100.0
	_rad_bar.value = g.get("radiation", 0.0)


func _refresh_hud() -> void:
	var w := SpaceWeather.info
	var live := " LIVE" if w.get("source") == "live" else ""
	_storm_label.text = "%s STORM%s" % [w.get("level", "..."), live]
	for i in SYSTEMS.size():
		_set_pips(_pips[i], int(GameState.power_plan.get(SYSTEMS[i], 0)))
	var total := get_tree().get_nodes_in_group(&"scroll").size()
	_samples_label.text = "%d/%d" % [GameState.scrolls.size(), total]


func _show_hint(text: String) -> void:
	_hint.text = text
	_hint.show()
	var tw := create_tween()
	tw.tween_interval(2.4)
	tw.tween_callback(_hint.hide)


func _play(stream: AudioStream) -> void:
	_sfx.stream = stream
	_sfx.play()


# ----------------------------------------------------------- pause menu ---

func _can_pause() -> bool:
	return _cinematic == 0 and not _plan_panel.visible and not _book.visible and not get_tree().paused


func _open_pause() -> void:
	_toast.hide()
	_pause.open()


func _open_book() -> void:
	_book_from_pause = true
	_book.open(GameState.level_id)


func _on_book_closed() -> void:
	if _book_from_pause:
		_pause.reopen()
	else:
		get_tree().paused = false


# ---------------------------------------------------------------- input ---

func _input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel"):
		if _pause.visible:
			return   # the pause screen handles its own ESC
		if not _book.visible and _can_pause():
			_open_pause()
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed(&"open_book") and _can_pause():
		_open_book_now()
		get_viewport().set_input_as_handled()
		return
	if not _plan_panel.visible:
		return
	if event.is_action_pressed(&"move_up") or event.is_action_pressed(&"ui_up"):
		_row = posmod(_row - 1, 3)
		_refresh_plan()
	elif event.is_action_pressed(&"move_down") or event.is_action_pressed(&"ui_down"):
		_row = posmod(_row + 1, 3)
		_refresh_plan()
	elif event.is_action_pressed(&"move_left") or event.is_action_pressed(&"ui_left"):
		_change(_row, -1)
	elif event.is_action_pressed(&"move_right") or event.is_action_pressed(&"ui_right"):
		_change(_row, 1)
	elif event.is_action_pressed(&"jump") or event.is_action_pressed(&"ui_accept"):
		if _bonus:
			_add_new_cell(_row)
		else:
			_confirm_plan()
	else:
		return
	get_viewport().set_input_as_handled()
