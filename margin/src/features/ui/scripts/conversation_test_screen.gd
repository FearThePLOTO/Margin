extends Control
## Temporary test bridge for the existing Conversation Module. The Main Menu
## START GAME button opens this retained screen, which presents a mock
## DialogueSequence through the reusable DialogueBox. After the conversation
## finishes, a back control returns to the Main Menu. This is not the final
## game progression flow, and no gameplay is implemented here.

signal back_requested

const MockConversation := preload("res://src/features/ui/scripts/mock_conversation.gd")

@onready var _dialogue: Control = %DialogueBox
@onready var _completed_panel: Control = %CompletedPanel
@onready var _back_button: Button = %BackButton

func _ready() -> void:
	hide()
	_completed_panel.hide()
	_dialogue.dialogue_finished.connect(_on_dialogue_finished)
	_back_button.pressed.connect(_on_back_pressed)

func open() -> void:
	show()
	_dialogue.start_dialogue(MockConversation.create_sequence())
	# start_dialogue() emits dialogue_finished first when it replaces an active
	# conversation, so the completed panel is hidden after the new line shows.
	_completed_panel.hide()

func close() -> void:
	# Safety: a hidden but still-active dialogue box would keep consuming
	# ui_accept through its global input handler.
	_dialogue.stop()
	_completed_panel.hide()
	if _back_button.has_focus():
		_back_button.release_focus()
	hide()

func is_test_running() -> bool:
	return visible

func _on_dialogue_finished() -> void:
	_completed_panel.show()
	_back_button.grab_focus.call_deferred()

func _on_back_pressed() -> void:
	if visible:
		back_requested.emit()
