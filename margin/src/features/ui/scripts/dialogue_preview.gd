extends Control
## Standalone visual preview for the reusable dialogue box. This scene owns its
## own temporary background and sample content; it is not attached to the Main
## Menu UI root or to any gameplay scene.

@onready var _dialogue: Control = %DialogueBox
@onready var _hint: Label = %Hint

func _ready() -> void:
	_dialogue.dialogue_started.connect(_on_dialogue_started)
	_dialogue.dialogue_finished.connect(_on_dialogue_finished)
	_start_preview.call_deferred()

func _start_preview() -> void:
	_hint.text = "ENTER / CLICK DIALOGUE TO CONTINUE"
	_dialogue.start_dialogue(_sample_sequence())

func _on_dialogue_started() -> void:
	_hint.text = "ENTER / CLICK DIALOGUE TO CONTINUE"

func _on_dialogue_finished() -> void:
	_hint.text = "DIALOGUE FINISHED - PRESS ENTER TO REPLAY"

func _unhandled_input(event: InputEvent) -> void:
	if _dialogue.is_dialogue_active():
		return
	if event.is_action_pressed("ui_accept") and not event.is_echo():
		_start_preview()
		get_viewport().set_input_as_handled()

func _sample_sequence() -> DialogueSequence:
	var sequence := DialogueSequence.new()
	sequence.lines = [
		_make_line("MISSION CONTROL", "MARGIN, THIS IS MISSION CONTROL. WE READ YOU LOUD AND CLEAR."),
		_make_line("MISSION CONTROL", "YOUR FIRST CHECKLIST IS READY. TAKE YOUR TIME AND READ EACH STEP CAREFULLY."),
		_make_line("MARGIN", "COPY THAT. I'M READY TO BEGIN THE LUNAR MISSION."),
		_make_line("MISSION CONTROL", "EXCELLENT. REMEMBER: SMALL STEPS FIRST, THEN THE BIG LEAP."),
	]
	return sequence

func _make_line(speaker: String, text: String) -> DialogueLine:
	var line := DialogueLine.new()
	line.speaker_name = speaker
	line.text = text
	return line
