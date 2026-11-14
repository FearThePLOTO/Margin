extends Area2D
## Scattered O2 tank pickup. Fixed refill (GameConstants.O2_TANK_PICKUP) when
## the player takes it, then the tank is consumed. Talks to the player's O2
## mechanic directly — mechanics-internal node, instanced by level scenes
## (same pattern as tether_anchor.tscn). No EventBus signals needed.

## Taken tanks come back when the player respawns (Celeste-style room reset),
## so dying after grabbing one can never soft-lock the air supply.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	EventBus.player_respawned.connect(_reset)


func _on_body_entered(body: Node2D) -> void:
	if visible and body.is_in_group(&"player"):
		var player := body as Player
		player.o2.add_supply(GameConstants.O2_TANK_PICKUP)
		GameState.tanks_taken += 1
		hide()
		set_deferred("monitoring", false)


func _reset() -> void:
	show()
	set_deferred("monitoring", true)
