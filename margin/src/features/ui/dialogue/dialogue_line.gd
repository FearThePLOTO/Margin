extends Resource
class_name DialogueLine
## One presented line of dialogue. Content authors can build these as .tres
## resources or construct them in code; the dialogue box only reads them.

@export var speaker_name: String = ""
## Leave empty to show the dialogue box's clearly marked portrait placeholder.
@export var portrait: Texture2D
@export_multiline var text: String = ""
