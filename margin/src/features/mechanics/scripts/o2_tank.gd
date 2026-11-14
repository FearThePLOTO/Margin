extends Area2D
## Scattered O2 tank pickup. Fixed refill (GameConstants.O2_TANK_PICKUP) when
## the player takes it, then the tank is consumed. Talks to the player's O2
## mechanic directly — mechanics-internal node, instanced by level scenes
## (same pattern as tether_anchor.tscn). No EventBus signals needed.

func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		var player := body as Player
		player.o2.add_supply(GameConstants.O2_TANK_PICKUP)
		queue_free()
