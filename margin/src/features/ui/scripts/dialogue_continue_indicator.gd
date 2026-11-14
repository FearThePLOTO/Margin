extends Control
## Small draw-only prompt shown when the current dialogue line is fully visible.
## Drawing the triangle avoids relying on a font glyph that Silkscreen may lack.

@export var indicator_color := Color(1.0, 1.0, 1.0, 0.85)

func _ready() -> void:
	resized.connect(queue_redraw)

func _draw() -> void:
	if size.x <= 0.0 or size.y <= 0.0:
		return
	draw_colored_polygon(
		PackedVector2Array([
			Vector2(0.0, 0.0),
			Vector2(size.x, 0.0),
			Vector2(size.x * 0.5, size.y),
		]),
		indicator_color
	)
