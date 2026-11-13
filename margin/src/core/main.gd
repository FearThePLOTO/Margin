extends Control
## Entry scene: drives the game flow hub -> mission -> debrief.
## Owned by the mechanics member (see features/mechanics/README.md).
## ui/ supplies the hub, loadout and debrief screens; this node swaps them
## by phase. Listen to EventBus for phase transitions.

func _ready() -> void:
	print("Margin: template ready. Flow: hub -> loadout -> mission -> debrief.")
	# TODO(mechanics): instantiate per-phase screens from features/ui/scenes/
	# based on GameState.phase and EventBus signals.
