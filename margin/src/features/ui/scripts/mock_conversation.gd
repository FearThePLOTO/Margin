extends RefCounted
## Temporary mock dialogue dataset for the START GAME test integration.
## Simple placeholder content only; this is not the final game story.
## The existing Conversation Module is linear, so there are no choices here.

static func create_sequence() -> DialogueSequence:
	var sequence := DialogueSequence.new()
	sequence.lines = [
		_make_line("MISSION CONTROL", "TEST SIGNAL. THIS IS A TEMPORARY MOCK CONVERSATION FOR UI VALIDATION ONLY."),
		_make_line("MISSION CONTROL", "PROGRESSION CHECK ONE. THE DIALOGUE BOX IS ADVANCING CORRECTLY."),
		_make_line("MARGIN", "PROGRESSION CHECK TWO. CONTINUING THE TEST SEQUENCE."),
		_make_line("MISSION CONTROL", "PROGRESSION CHECK THREE. THE CONVERSATION WILL END AFTER THIS LINE."),
		_make_line("MARGIN", "TEST CONVERSATION COMPLETE. READY TO RETURN TO THE MAIN MENU."),
	]
	return sequence

static func _make_line(speaker: String, text: String) -> DialogueLine:
	var line := DialogueLine.new()
	line.speaker_name = speaker
	line.text = text
	return line
