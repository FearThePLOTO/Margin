extends Control
## Main menu. START GAME starts the mission (src/core/main.gd swaps in Level 1),
## SETTINGS opens audio settings, NASA DATA lists the real datasets used.

signal start_game_requested
signal settings_requested
signal data_requested
signal book_requested

const _STATUS_START := "LAUNCHING MISSION..."

@onready var _start_button: Button = %StartButton
@onready var _settings_button: Button = %SettingsButton
@onready var _quit_button: Button = %QuitButton
@onready var _data_button: Button = %DataButton
@onready var _book_button: Button = %BookButton
@onready var _status: Label = %Status
@onready var _quit_dialog = %QuitConfirmDialog
@onready var _selection_underline = %SelectionUnderline

var _menu_buttons: Array[Button] = []

func _ready() -> void:
	_menu_buttons.clear()
	for child in find_children("*", "Button", true, false):
		var button := child as Button
		if button.theme_type_variation == &"MenuOptionButton":
			_menu_buttons.append(button)
			button.focus_entered.connect(_on_menu_option_focused.bind(button))
			button.focus_exited.connect(_on_menu_option_unfocused)

	_start_button.pressed.connect(_on_start_pressed)
	_settings_button.pressed.connect(_on_settings_pressed)
	_quit_button.pressed.connect(_on_quit_pressed)
	_data_button.pressed.connect(_on_data_pressed)
	_book_button.pressed.connect(_on_book_pressed)
	_quit_dialog.closed.connect(_on_quit_closed)
	if is_visible_in_tree():
		_start_button.grab_focus()

func focus_default() -> void:
	_start_button.grab_focus()

func focus_settings() -> void:
	_settings_button.grab_focus()

func _on_menu_option_focused(button: Button) -> void:
	_selection_underline.show_for(button)

func _on_menu_option_unfocused() -> void:
	# Let the new focus owner settle first. Moving between options must not
	# hide the indicator, but moving into the quit dialog must.
	_hide_underline_if_focus_left.call_deferred()

func _hide_underline_if_focus_left() -> void:
	if not _menu_buttons.has(get_viewport().gui_get_focus_owner()):
		_selection_underline.hide_indicator()

func _on_start_pressed() -> void:
	_status.text = _STATUS_START
	start_game_requested.emit()

func _on_settings_pressed() -> void:
	_selection_underline.hide_indicator()
	settings_requested.emit()

func focus_book() -> void:
	_book_button.grab_focus()

func _on_book_pressed() -> void:
	_selection_underline.hide_indicator()
	book_requested.emit()

func focus_data() -> void:
	_data_button.grab_focus()

func _on_data_pressed() -> void:
	_selection_underline.hide_indicator()
	data_requested.emit()

func _on_quit_pressed() -> void:
	_selection_underline.hide_indicator()
	_set_buttons_focusable(false)
	_quit_dialog.open()

func _on_quit_closed(confirmed: bool) -> void:
	_set_buttons_focusable(true)
	_quit_button.grab_focus()
	if confirmed:
		get_tree().quit()

func _set_buttons_focusable(enabled: bool) -> void:
	var mode := Control.FOCUS_ALL if enabled else Control.FOCUS_NONE
	_start_button.focus_mode = mode
	_settings_button.focus_mode = mode
	_quit_button.focus_mode = mode
	_data_button.focus_mode = mode
	_book_button.focus_mode = mode
