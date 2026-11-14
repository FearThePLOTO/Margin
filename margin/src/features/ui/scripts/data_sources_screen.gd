extends Control
## "NASA DATA" screen: which real datasets the game uses, how, and what is
## game-only. Opened from the main menu so players and judges can trace the
## science. Content lives in the RichTextLabel in data_sources_screen.tscn.

signal back_requested

@onready var _back: Button = %BackButton
@onready var _text: RichTextLabel = %SourcesText


func _ready() -> void:
	hide()
	_back.pressed.connect(func() -> void: back_requested.emit())


func open() -> void:
	show()
	_text.scroll_to_line(0)
	_back.grab_focus.call_deferred()


func close() -> void:
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return
	if event.is_action_pressed(&"ui_down") or event.is_action_pressed(&"move_down"):
		_text.get_v_scroll_bar().value += 12
	elif event.is_action_pressed(&"ui_up") or event.is_action_pressed(&"move_up"):
		_text.get_v_scroll_bar().value -= 12
	elif event.is_action_pressed(&"ui_cancel"):
		back_requested.emit()
