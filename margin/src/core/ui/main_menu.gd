extends Control
## Main menu, after the proposal's opening (slide 5) title card:
##  1. a dense Mars dust storm blows (storm_background.gd)
##  2. MARGIN pops in letter by letter, the tagline types itself out,
##     "PRESS ENTER TO CONTINUE" blinks (any key skips the intro)
##  3. ENTER: the logo rises and the choices appear, storm still blowing:
##     START NEW GAME / CONTINUE (needs a checkpoint save) / OPTIONS / EXIT
## main.gd listens to new_game_requested / continue_requested.

signal new_game_requested
signal continue_requested

enum { INTRO, TITLE, MENU, BUSY }
enum { NEW_GAME, CONTINUE, OPTIONS, EXIT }

const LETTER_START_S := 0.5
const LETTER_STEP_S := 0.16
const TAG_START_S := 1.6
const TAG_CHAR_S := 0.028
const PROMPT_START_S := 2.6
const LOGO_TITLE_Y := 44.0
const LOGO_MENU_Y := 10.0

## Coming back from a level skips the title card and goes straight to the menu.
static var _title_seen := false

@onready var _storm = %Storm  # storm_background.gd
@onready var _logo: Control = %Logo
@onready var _tagline: Label = %Tagline
@onready var _prompt: Label = %Prompt
@onready var _menu: PixelMenu = %MainList
@onready var _footer: Label = %Footer
@onready var _options = %Options  # settings_panel.gd
@onready var _data = %DataSources  # features data_sources_screen.gd
@onready var _confirm: Control = %Confirm
@onready var _confirm_list: PixelMenu = %ConfirmList
@onready var _fade: ColorRect = %Fade

var _state := INTRO
var _t := 0.0
var _letters: Array[Control] = []


func _ready() -> void:
	for c in _logo.get_children():
		_letters.append(c as Control)
	_menu.chosen.connect(_on_chosen)
	_confirm_list.chosen.connect(_on_confirm)
	_options.closed.connect(_on_options_closed)
	_options.data_requested.connect(_on_data_requested)
	_data.back_requested.connect(_on_data_back)
	_menu.set_disabled(CONTINUE, not GameState.has_run_save())
	if OS.has_feature("web"):
		_menu.set_disabled(EXIT, true)
	_confirm.hide()
	_menu.active = false
	_menu.modulate.a = 0.0
	_footer.modulate.a = 0.0
	_fade.color.a = 1.0
	create_tween().tween_property(_fade, "color:a", 0.0, 0.6)
	if _title_seen:
		_finish_intro()
		_to_menu(false)
	else:
		_tagline.visible_characters = 0
		_prompt.modulate.a = 0.0
		for l in _letters:
			l.hide()


func _process(delta: float) -> void:
	_t += delta
	if _state == INTRO:
		for i in _letters.size():
			var a := _t - (LETTER_START_S + i * LETTER_STEP_S)
			_letters[i].visible = a >= 0.0
			_letters[i].modulate.a = 0.5 if a < 0.12 else 1.0
		_tagline.visible_characters = maxi(0, int((_t - TAG_START_S) / TAG_CHAR_S))
		if _t > PROMPT_START_S and _tagline.visible_ratio >= 1.0:
			_finish_intro()
	if _state == TITLE:
		_prompt.modulate.a = 0.45 + 0.4 * (0.5 + 0.5 * cos(_t * 3.0))


func _finish_intro() -> void:
	_state = TITLE
	for l in _letters:
		l.show()
		l.modulate.a = 1.0
	_tagline.visible_characters = -1


func _to_menu(animate := true) -> void:
	_state = MENU
	_title_seen = true
	var d := 0.45 if animate else 0.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_logo, "position:y", LOGO_MENU_Y, maxf(d, 0.01)).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(_tagline, "modulate:a", 0.0, maxf(d * 0.5, 0.01))
	tw.tween_property(_prompt, "modulate:a", 0.0, maxf(d * 0.5, 0.01))
	tw.tween_property(_storm, "band_y", 112.0, maxf(d, 0.01))
	tw.tween_property(_storm, "band_half_height", 46.0, maxf(d, 0.01))
	tw.tween_property(_menu, "modulate:a", 1.0, maxf(d, 0.01)).set_delay(d * 0.5)
	tw.tween_property(_footer, "modulate:a", 1.0, maxf(d, 0.01)).set_delay(d * 0.5)
	_menu.selected = CONTINUE if not _menu.is_disabled(CONTINUE) else NEW_GAME
	_menu.active = true
	_menu.queue_redraw()


func _to_title() -> void:
	_state = TITLE
	_menu.active = false
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_logo, "position:y", LOGO_TITLE_Y, 0.35).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_tagline, "modulate:a", 1.0, 0.3)
	tw.tween_property(_menu, "modulate:a", 0.0, 0.2)
	tw.tween_property(_footer, "modulate:a", 0.0, 0.2)
	tw.tween_property(_storm, "band_y", 80.0, 0.35)
	tw.tween_property(_storm, "band_half_height", 40.0, 0.35)


func _on_chosen(i: int) -> void:
	match i:
		NEW_GAME:
			if GameState.has_run_save() or BookOfBooks.has_progress():
				_menu.active = false
				_confirm.show()
				_confirm_list.selected = 1
				_confirm_list.active = true
				_confirm_list.queue_redraw()
			else:
				_launch(new_game_requested)
		CONTINUE:
			_launch(continue_requested)
		OPTIONS:
			_menu.active = false
			_options.open()
		EXIT:
			_state = BUSY
			_menu.active = false
			var tw := create_tween()
			tw.tween_property(_fade, "color:a", 1.0, 0.4)
			tw.tween_callback(get_tree().quit)


func _on_confirm(i: int) -> void:
	_confirm_list.active = false
	_confirm.hide()
	if i == 0:
		_launch(new_game_requested)
	else:
		_menu.active = true


func _launch(sig: Signal) -> void:
	_state = BUSY
	_menu.active = false
	var tw := create_tween()
	tw.tween_property(_fade, "color:a", 1.0, 0.5)
	tw.tween_callback(func() -> void: sig.emit())


func _on_options_closed() -> void:
	_menu.active = true


func _on_data_requested() -> void:
	_options.hide()
	_data.open()


func _on_data_back() -> void:
	_data.close()
	_options.open()


func _input(event: InputEvent) -> void:
	var pressed := event.is_pressed() and not event.is_echo() and (event is InputEventKey \
			or event is InputEventMouseButton or event is InputEventJoypadButton)
	if not pressed:
		return
	match _state:
		INTRO:
			_finish_intro()
			get_viewport().set_input_as_handled()
		TITLE:
			_to_menu()
			get_viewport().set_input_as_handled()
		MENU:
			if event.is_action_pressed(&"ui_cancel") and _menu.active:
				_to_title()
				get_viewport().set_input_as_handled()
			elif _confirm.visible and event.is_action_pressed(&"ui_cancel"):
				_on_confirm(1)
				get_viewport().set_input_as_handled()
