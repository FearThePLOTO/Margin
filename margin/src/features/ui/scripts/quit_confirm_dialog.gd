extends Control
## Small local confirmation overlay. NO is focused by default and Escape always
## closes it without quitting, so the player cannot quit by accident.

signal closed(confirmed: bool)

@onready var _no_button: Button = %NoButton
@onready var _yes_button: Button = %YesButton
@onready var _selection_underline = %SelectionUnderline

var _options: Array[Button] = []

func _ready() -> void:
	hide()
	_options = [_no_button, _yes_button]
	for button in _options:
		button.focus_entered.connect(_on_option_focused.bind(button))
		button.focus_exited.connect(_on_option_unfocused)
	_no_button.pressed.connect(_on_choice.bind(false))
	_yes_button.pressed.connect(_on_choice.bind(true))
	_selection_underline.hide_indicator()

func open() -> void:
	_selection_underline.hide_indicator()
	show()
	# Focus after the container has placed the panel. The underline's first
	# show is deferred too, so this avoids measuring the pre-layout button box.
	_focus_default.call_deferred()

func _focus_default() -> void:
	if visible:
		_no_button.grab_focus()

func _on_option_focused(button: Button) -> void:
	_selection_underline.show_for(button)

func _on_option_unfocused() -> void:
	_hide_underline_if_focus_left.call_deferred()

func _hide_underline_if_focus_left() -> void:
	if not _options.has(get_viewport().gui_get_focus_owner()):
		_selection_underline.hide_indicator()

func _on_choice(confirmed: bool) -> void:
	if not visible:
		return
	_selection_underline.hide_indicator()
	hide()
	closed.emit(confirmed)

func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_on_choice(false)
