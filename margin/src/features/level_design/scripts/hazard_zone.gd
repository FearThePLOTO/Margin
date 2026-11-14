extends Area2D
## Hazard zone. Level-design convention (see this feature's README): the node's
## name IS the zone_id (e.g. RadioactiveWastes, PermanentShadow,
## SolarStormZone, LooseRegolith). Emits on the EventBus only — the player
## (mechanics feature) listens and accrues gauges; never reference the player
## scene directly from here.
##
## Set zone_id when several pools share one hazard type (e.g. every lava pool
## is &"LavaZone") but each node needs a unique name.

@export var zone_id: StringName = &""
## Instant-death zone (e.g. lava): entering plays the player's death effect
## and respawns them at the checkpoint, instead of accruing a gauge.
@export var kill_on_touch := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func _zone_id() -> StringName:
	return zone_id if zone_id != &"" else StringName(name)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group(&"player"):
		return
	if kill_on_touch:
		EventBus.hazard_kill.emit(_zone_id())
		return
	EventBus.hazard_entered.emit(_zone_id())


func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		EventBus.hazard_exited.emit(_zone_id())
