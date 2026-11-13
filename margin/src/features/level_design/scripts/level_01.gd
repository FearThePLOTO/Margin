extends Node2D
## Room framing. Rooms 2 and 3 are exactly one 320x180 screen, so the camera
## locks to the room rect while the player is inside it and follows freely
## everywhere else. Rooms are listed in the inspector (rects in level space).

@export var world_bounds := Rect2(48, -224, 1776, 672)
@export var rooms: Array[Rect2] = []

var _inside := -1

@onready var _camera: Camera2D = $Player.camera


func _ready() -> void:
	_apply(world_bounds)


func _physics_process(_delta: float) -> void:
	var found := -1
	for i in rooms.size():
		if rooms[i].has_point($Player.global_position):
			found = i
			break
	if found == _inside:
		return
	_inside = found
	_apply(rooms[found] if found >= 0 else world_bounds)


func _apply(rect: Rect2) -> void:
	_camera.limit_left = int(rect.position.x)
	_camera.limit_top = int(rect.position.y)
	_camera.limit_right = int(rect.end.x)
	_camera.limit_bottom = int(rect.end.y)
	_camera.reset_smoothing()
