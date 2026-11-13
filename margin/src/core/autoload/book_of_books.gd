extends Node
## The Book of Books: every mission failure writes a note here.
## The debrief screen (ui feature) reads and displays these notes.

signal note_added(note: Dictionary)

var notes: Array[Dictionary] = []

func add_note(entry_id: StringName, reason: String, data: Dictionary = {}) -> void:
	var note := {"entry_id": entry_id, "reason": reason, "data": data}
	notes.append(note)
	note_added.emit(note)

func get_notes() -> Array[Dictionary]:
	return notes
