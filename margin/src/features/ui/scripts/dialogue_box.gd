extends Control
## Reusable dialogue presentation overlay. It owns only the dialogue box: no
## gameplay, player movement, story progression, or Main Menu background.
##
## Start a conversation with start_dialogue(sequence). Both ui_accept and a left
## click on the box reveal a typing line, then advance it. The final line stays
## on screen until one more valid interaction closes the box.

signal dialogue_started
signal dialogue_finished

@export_range(10.0, 80.0, 1.0) var characters_per_second := 32.0

@onready var _frame_root: Control = %FrameRoot
@onready var _name_label: Label = %NameLabel
@onready var _text_label: RichTextLabel = %DialogueText
@onready var _portrait_texture: TextureRect = %PortraitTexture
@onready var _portrait_placeholder: Control = %PortraitPlaceholder
@onready var _continue_indicator: Control = %ContinueIndicator

var _sequence: DialogueSequence
var _line_index := -1
var _active := false
var _line_complete := false
var _typewriter_progress := 0.0

func _ready() -> void:
	hide()
	_continue_indicator.hide()
	_text_label.visible_characters = 0
	set_process(false)

## Presents an authored sequence. An empty sequence is ignored so callers can
## safely pass optional conversations without opening an empty box.
func start_dialogue(sequence: DialogueSequence) -> void:
	if sequence == null or sequence.lines.is_empty():
		push_warning("DialogueBox.start_dialogue() needs at least one line.")
		return

	# Replacing a conversation closes the old one first, keeping the
	# started/finished signal pairs balanced for future game systems.
	if _active:
		_finish_dialogue()

	_sequence = sequence
	_line_index = 0
	_active = true
	show()
	_show_line(0)
	dialogue_started.emit()

func is_dialogue_active() -> bool:
	return _active

func get_current_line_index() -> int:
	return _line_index

func is_current_line_complete() -> bool:
	return _line_complete

## Closes an active conversation without starting a new one. Emits
## dialogue_finished only if a conversation was open, keeping the
## started/finished signal pairs balanced.
func stop() -> void:
	if _active:
		_finish_dialogue()

func _show_line(index: int) -> void:
	var line := _sequence.lines[index]
	_name_label.text = line.speaker_name if not line.speaker_name.is_empty() else "UNKNOWN"
	_text_label.text = line.text
	_text_label.visible_characters = 0
	_typewriter_progress = 0.0
	_line_complete = false
	_continue_indicator.hide()
	_update_portrait(line.portrait)

	if line.text.is_empty():
		_complete_line()
	else:
		set_process(true)

func _update_portrait(texture: Texture2D) -> void:
	_portrait_texture.texture = texture
	_portrait_texture.visible = texture != null
	_portrait_placeholder.visible = texture == null

func _process(delta: float) -> void:
	if not _active or _line_complete:
		return

	_typewriter_progress += delta * characters_per_second
	var total := _text_label.get_total_character_count()
	if total <= 0:
		_complete_line()
		return

	var revealed := int(_typewriter_progress)
	if revealed >= total:
		_complete_line()
	else:
		_text_label.visible_characters = revealed

func _complete_line() -> void:
	_line_complete = true
	_typewriter_progress = float(_text_label.get_total_character_count())
	_text_label.visible_characters = _text_label.get_total_character_count()
	_continue_indicator.show()
	set_process(false)

func _reveal_current_line() -> void:
	_complete_line()

func _request_advance() -> void:
	if not _active:
		return

	if not _line_complete:
		_reveal_current_line()
		return

	if _line_index < _sequence.lines.size() - 1:
		_line_index += 1
		_show_line(_line_index)
	else:
		_finish_dialogue()

func _finish_dialogue() -> void:
	if not _active:
		return

	_active = false
	_line_index = -1
	_line_complete = false
	_typewriter_progress = 0.0
	_continue_indicator.hide()
	set_process(false)
	hide()
	dialogue_finished.emit()

func _input(event: InputEvent) -> void:
	if not _active or not visible:
		return

	if event.is_action_pressed("ui_accept") and not event.is_echo():
		_request_advance()
		get_viewport().set_input_as_handled()
		return

	if event is InputEventMouseButton:
		var mouse := event as InputEventMouseButton
		if mouse.pressed and mouse.button_index == MOUSE_BUTTON_LEFT \
				and _frame_root.get_global_rect().has_point(mouse.position):
			_request_advance()
			get_viewport().set_input_as_handled()
