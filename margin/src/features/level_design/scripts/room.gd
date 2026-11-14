extends Area2D
## Celeste-style room. Drag room.tscn into a level, then resize its Shape
## (right-click the Shape's RectangleShape2D -> Make Unique first) and move the
## Spawn marker to where the player should reappear after dying here.
## Entering the room locks the camera to the rectangle and moves the respawn
## point. Rooms should be at least one screen (320x180) in size.

@onready var _shape: CollisionShape2D = $Shape
@onready var _spawn: Marker2D = $Spawn


func _ready() -> void:
	add_to_group(&"room")
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)


func get_rect() -> Rect2:
	var size := (_shape.shape as RectangleShape2D).size
	return Rect2(_shape.global_position - size * 0.5, size)


func activate() -> void:
	EventBus.room_entered.emit(get_rect())
	EventBus.checkpoint_reached.emit(_spawn.global_position)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		activate()


## Walking back across a shared edge never fires body_entered on the room you
## never left, so hand control to whichever other room still holds the player.
func _on_body_exited(body: Node2D) -> void:
	if not body.is_in_group(&"player"):
		return
	for room: Node in get_tree().get_nodes_in_group(&"room"):
		if room != self and (room as Area2D).overlaps_body(body):
			room.call(&"activate")
			return
