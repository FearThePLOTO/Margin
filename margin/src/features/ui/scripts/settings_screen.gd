extends Control
## Audio Settings screen. The shared UI background stays in the UI root, so this
## screen is transparent and only replaces the Main Menu content. Volume levels
## are local to this retained screen instance; no audio bus or audio feature is
## touched here.

signal back_requested

const AudioSettingRowScript = preload("res://src/features/ui/scripts/audio_setting_row.gd")

@onready var _music_row: AudioSettingRowScript = %MusicRow
@onready var _sound_row: AudioSettingRowScript = %SoundEffectsRow
@onready var _back_button: Button = %BackButton
@onready var _selection_underline = %SelectionUnderline

var _focus_buttons: Array[Button] = []

func _ready() -> void:
	hide()
	_focus_buttons = [
		_music_row.label_button,
		_sound_row.label_button,
		_back_button,
	]
	for button in _focus_buttons:
		button.focus_entered.connect(_on_focus_entered.bind(button))
		button.focus_exited.connect(_on_focus_exited)
	_back_button.pressed.connect(_on_back_pressed)
	_configure_focus_order()
	_selection_underline.hide_indicator()
	_set_selected_row(null)

func open() -> void:
	show()
	focus_default.call_deferred()

func close() -> void:
	_selection_underline.hide_indicator()
	_set_selected_row(null)
	for button in _focus_buttons:
		if button.has_focus():
			button.release_focus()
	hide()

func focus_default() -> void:
	if visible:
		_music_row.label_button.grab_focus()

func _configure_focus_order() -> void:
	var music := _focus_buttons[0]
	var sound := _focus_buttons[1]
	var back := _focus_buttons[2]
	music.focus_next = music.get_path_to(sound)
	music.focus_previous = music.get_path_to(back)
	sound.focus_next = sound.get_path_to(back)
	sound.focus_previous = sound.get_path_to(music)
	back.focus_next = back.get_path_to(music)
	back.focus_previous = back.get_path_to(sound)

func _input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_left"):
		_adjust_focused_volume(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
		_adjust_focused_volume(1)
		get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_back_pressed()

func _adjust_focused_volume(delta: int) -> void:
	var focus := get_viewport().gui_get_focus_owner()
	if focus == _music_row.label_button:
		_music_row.level += delta
	elif focus == _sound_row.label_button:
		_sound_row.level += delta

func _on_focus_entered(button: Button) -> void:
	_selection_underline.show_for(button)
	_set_selected_row(button)

func _on_focus_exited() -> void:
	# Let the new focus owner settle first. Moving between the three options
	# must keep the indicator visible, while moving out must hide it.
	_hide_underline_if_focus_left.call_deferred()

func _hide_underline_if_focus_left() -> void:
	var focus := get_viewport().gui_get_focus_owner()
	if not _focus_buttons.has(focus):
		_selection_underline.hide_indicator()
		_set_selected_row(null)

func _set_selected_row(button: Button) -> void:
	_music_row.set_selected(button == _music_row.label_button)
	_sound_row.set_selected(button == _sound_row.label_button)

func _on_back_pressed() -> void:
	if visible:
		back_requested.emit()
