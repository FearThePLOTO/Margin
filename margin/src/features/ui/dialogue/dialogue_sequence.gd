extends Resource
class_name DialogueSequence
## Ordered content for one conversation. This keeps authored dialogue separate
## from the reusable dialogue presentation scene.

@export var lines: Array[DialogueLine] = []
