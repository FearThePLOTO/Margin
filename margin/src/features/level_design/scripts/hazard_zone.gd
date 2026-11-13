extends Area2D
## Hazard zone. Level-design convention (see this feature's README): the node's
## name IS the zone_id (e.g. RadioactiveWastes, PermanentShadow,
## SolarStormZone, LooseRegolith). Emits on the EventBus only — the player
## (mechanics feature) listens and accrues gauges; never reference the player
## scene directly from here.

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		EventBus.hazard_entered.emit(StringName(name))


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		EventBus.hazard_exited.emit(StringName(name))
