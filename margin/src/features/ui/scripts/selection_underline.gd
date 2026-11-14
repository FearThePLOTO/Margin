extends Node2D
## Reusable short selection indicator for menu buttons.
##
## A single instance slides between focused options, so there can never be a
## stale underline left behind on another button. The shape is a short,
## constant-thickness bar: the central portion of the former tapered underline.

const _THEME_TYPE := &"MenuOptionButton"
const _MOVE_TIME := 0.12
const _WIDTH_FACTOR := 0.5

var width := 0.0:
	set(value):
		width = maxf(0.0, value)
		queue_redraw()

var _tween: Tween
var _target_button: Button
var _show_queued := false
var _color := Color.WHITE
var _thickness := 3.0

func _ready() -> void:
	visible = false

## Moves the indicator beneath the supplied option. Animate only when it is
## already visible; first show and dialog-close snaps avoid a slide from a
## stale position.
func show_for(button: Button, animate := true) -> void:
	if button == null:
		hide_indicator()
		return

	_target_button = button
	_read_style(button)
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null

	if not animate or not visible:
		# A hidden menu can be focused before its container has sorted. Queue
		# the first placement so the indicator never appears at a stale origin.
		_show_queued = true
		_show_at_target.call_deferred()
		return

	var target := _target_for(button)
	show()
	_tween = create_tween()
	_tween.set_trans(Tween.TRANS_QUAD)
	_tween.set_ease(Tween.EASE_OUT)
	_tween.tween_property(self, "position", target.position, _MOVE_TIME)
	_tween.parallel().tween_property(self, "width", target.width, _MOVE_TIME)

func hide_indicator() -> void:
	_show_queued = false
	if _tween != null and _tween.is_valid():
		_tween.kill()
	_tween = null
	hide()

func _show_at_target() -> void:
	if not _show_queued:
		return
	_show_queued = false
	if _target_button == null or not is_instance_valid(_target_button):
		return
	if not _target_button.has_focus():
		return

	var target := _target_for(_target_button)
	position = target.position
	width = target.width
	queue_redraw()
	show()

## Exposed so layout and shape checks can inspect the actual geometry that
## _draw uses without duplicating the bar math.
func get_shape_points() -> PackedVector2Array:
	var half_width := width * 0.5
	var half_thickness := _thickness * 0.5
	return PackedVector2Array([
		Vector2(-half_width, -half_thickness),
		Vector2(half_width, -half_thickness),
		Vector2(half_width, half_thickness),
		Vector2(-half_width, half_thickness),
	])

func _draw() -> void:
	if width <= 0.5:
		return
	draw_colored_polygon(get_shape_points(), _color)

func _read_style(button: Button) -> void:
	_color = button.get_theme_color("underline_color", _THEME_TYPE)
	_thickness = float(button.get_theme_constant("underline_center_thickness", _THEME_TYPE))
	queue_redraw()

func _target_for(button: Button) -> Dictionary:
	var font := button.get_theme_font("font")
	if font == null:
		return {"position": Vector2.ZERO, "width": 0.0}

	var font_size := button.get_theme_font_size("font_size")
	var text_size := font.get_string_size(button.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
	var padding := float(button.get_theme_constant("underline_padding", _THEME_TYPE))
	var gap := float(button.get_theme_constant("underline_gap", _THEME_TYPE))
	var thickness := float(button.get_theme_constant("underline_center_thickness", _THEME_TYPE))
	var line_width := (text_size.x + padding * 2.0) * _WIDTH_FACTOR
	line_width = clampf(roundf(line_width), 1.0, maxf(1.0, button.size.x - 8.0))

	var button_rect := button.get_global_rect()
	var parent_control := get_parent() as Control
	if parent_control == null:
		return {"position": Vector2.ZERO, "width": 0.0}
	var to_parent := parent_control.get_global_transform().affine_inverse()
	var text_bottom := button_rect.get_center().y + text_size.y * 0.5
	var center := to_parent * Vector2(
		button_rect.get_center().x,
		text_bottom + gap + thickness * 0.5
	)
	return {"position": center, "width": line_width}
