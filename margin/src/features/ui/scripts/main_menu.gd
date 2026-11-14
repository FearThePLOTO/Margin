extends Control
## Main menu for the UI prototype.
## START GAME opens the temporary Conversation Module test until gameplay
## exists. SETTINGS opens the local audio settings screen. Local signals mark
## the future integration points.

signal start_game_requested
signal settings_requested

const _STATUS_START := "CONVERSATION TEST CONNECTED."

@onready var _start_button: Button = %StartButton
@onready var _settings_button: Button = %SettingsButton
@onready var _quit_button: Button = %QuitButton
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
