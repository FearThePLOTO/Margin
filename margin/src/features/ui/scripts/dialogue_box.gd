extends Control
## Reusable dialogue presentation overlay (Celeste-style, top of screen).
##  - Character lines: illustrated portrait on the speaker's side
##    (DialogueLine.portrait_on_right), name, typewriter text with voice blips.
##  - NASA lines (speaker_name starting with "NASA"): a green uplink terminal
##    with "> " prompts and a blinking cursor instead of a portrait.
## BBCode effects work in text ([shake], [wave]); DialogueLine.shake_box jolts
## the box. Start with start_dialogue(sequence). ui_accept or a click on the
## box reveals the line, then advances; the last line closes the box.

signal dialogue_started
signal dialogue_finished
signal line_started(speaker: String, has_sfx: bool)

@export_range(10.0, 80.0, 1.0) var characters_per_second := 34.0
@export_range(10.0, 120.0, 1.0) var terminal_characters_per_second := 52.0

const _VOICE_EVERY := 2
const _CURSOR_BLINK_S := 0.45

@onready var _frame_root: Control = %FrameRoot
@onready var _portrait_frame: Control = %PortraitFrame
@onready var _terminal_frame: Control = %TerminalFrame
@onready var _name_label: Label = %NameLabel
@onready var _story_text: RichTextLabel = %DialogueText
@onready var _term_text: RichTextLabel = %TermText
@onready var _portrait_left: TextureRect = %PortraitLeft
@onready var _portrait_right: TextureRect = %PortraitRight
@onready var _continue_indicator: Control = %ContinueIndicator

var _sequence: DialogueSequence
var _line_index := -1
var _active := false
var _line_complete := false
var _typewriter_progress := 0.0
var _text_label: RichTextLabel
var _terminal := false
var _cursor_t := 0.0
var _voice_player: AudioStreamPlayer
var _sfx_player: AudioStreamPlayer
var _last_voiced := 0


func _ready() -> void:
	_voice_player = AudioStreamPlayer.new()
	_sfx_player = AudioStreamPlayer.new()
	for p in [_voice_player, _sfx_player]:
		p.bus = &"SFX"
		add_child(p)
	_text_label = _story_text
	hide()
	_continue_indicator.hide()
	set_process(false)


func start_dialogue(sequence: DialogueSequence) -> void:
	if sequence == null or sequence.lines.is_empty():
		push_warning("DialogueBox.start_dialogue() needs at least one line.")
		return
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


func stop() -> void:
	if _active:
		_finish_dialogue()


func _show_line(index: int) -> void:
	var line := _sequence.lines[index]
	_terminal = line.speaker_name.begins_with("NASA")
	_portrait_frame.visible = not _terminal
	_terminal_frame.visible = _terminal
	if _terminal:
		_text_label = _term_text
		_text_label.text = "> " + line.text + " _"
	else:
		_text_label = _story_text
		_name_label.text = line.speaker_name
		_name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT if line.portrait_on_right else HORIZONTAL_ALIGNMENT_LEFT
		_portrait_left.texture = null if line.portrait_on_right else line.portrait
		_portrait_right.texture = line.portrait if line.portrait_on_right else null
		_portrait_left.get_parent().visible = not line.portrait_on_right
		_portrait_right.get_parent().visible = line.portrait_on_right
		_text_label.text = line.text
	_text_label.visible_characters = 0
	_typewriter_progress = 0.0
	_line_complete = false
	_continue_indicator.hide()
	_last_voiced = 0
	line_started.emit(line.speaker_name, line.sfx != null)
	if line.shake_box:
		_jolt()
	if line.sfx:
		_sfx_player.stream = line.sfx
		_sfx_player.play()
	set_process(true)


func _process(delta: float) -> void:
	if not _active:
		return
	var total := _text_label.get_total_character_count()
	if _line_complete:
		if _terminal:  # blinking cursor
			_cursor_t += delta
			_text_label.visible_characters = total if int(_cursor_t / _CURSOR_BLINK_S) % 2 == 0 else total - 1
		return
	var cps := terminal_characters_per_second if _terminal else characters_per_second
	_typewriter_progress += delta * cps
	var revealed := int(_typewriter_progress)
	if total <= 0 or revealed >= total:
		_complete_line()
	else:
		_text_label.visible_characters = revealed
		_play_voice(revealed)


func _complete_line() -> void:
	_line_complete = true
	_cursor_t = 0.0
	_text_label.visible_characters = _text_label.get_total_character_count()
	_continue_indicator.show()


## Celeste-style box jolt: a few fast random offsets that settle back.
func _jolt() -> void:
	var base := _frame_root.position
	var tw := create_tween()
	for i in 6:
		var amp := 3.0 * (1.0 - i / 6.0)
		tw.tween_property(_frame_root, "position", base + Vector2(randf_range(-amp, amp), randf_range(-amp, amp)), 0.03)
	tw.tween_property(_frame_root, "position", base, 0.03)


func _play_voice(revealed: int) -> void:
	var line := _sequence.lines[_line_index]
	if line.voice == null or revealed - _last_voiced < _VOICE_EVERY:
		return
	_last_voiced = revealed
	var ch := _text_label.get_parsed_text().substr(revealed - 1, 1)
	if ch.strip_edges().is_empty():
		return
	_voice_player.stream = line.voice
	_voice_player.pitch_scale = line.voice_pitch * randf_range(0.88, 1.14)
	_voice_player.play()


func _request_advance() -> void:
	if not _active:
		return
	if not _line_complete:
		_complete_line()
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
