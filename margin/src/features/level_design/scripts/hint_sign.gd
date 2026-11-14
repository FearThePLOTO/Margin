extends Area2D
## Tutorial sign: shows its text while the player stands near it.
## The bubble sits above the sign but is kept inside the camera view, so a
## sign near a room edge never pushes its text off screen.

@export_multiline var text := "LEFT / RIGHT to walk"

const ABOVE_PX := 34.0
const SCREEN_MARGIN_PX := 4.0

@onready var _label: Label = $Label


func _ready() -> void:
	_label.text = text
	_label.hide()
	set_process(false)
	body_entered.connect(_on_enter)
	body_exited.connect(_on_exit)


func _on_enter(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		_label.show()
		_label.reset_size()
		set_process(true)
		_process(0.0)


func _on_exit(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		_label.hide()
		set_process(false)


func _process(_delta: float) -> void:
	var view := get_viewport().get_canvas_transform().affine_inverse() * get_viewport().get_visible_rect()
	var size := _label.size
	var want := global_position + Vector2(-size.x * 0.5, -ABOVE_PX)
	var lo := view.position + Vector2.ONE * SCREEN_MARGIN_PX
	var hi := view.end - size - Vector2.ONE * SCREEN_MARGIN_PX
	_label.global_position = Vector2(clampf(want.x, lo.x, maxf(lo.x, hi.x)), clampf(want.y, lo.y, maxf(lo.y, hi.y))).round()
