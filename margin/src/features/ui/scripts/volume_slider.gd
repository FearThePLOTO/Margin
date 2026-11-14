extends Control
## Horizontal discrete volume slider drawn as a one-pixel track and ten short
## vertical ticks. Level 0 is mute (no illuminated ticks); level 10 fills the
## entire track. Mouse clicks map to the nearest level; keyboard changes are
## applied by the Settings screen.

signal level_changed(level: int)
signal activated

const STEP_COUNT := 10
const TICK_WIDTH := 1.0

@export_range(0, 10, 1) var level: int = 7:
	set(value):
		var next_level := clampi(value, 0, STEP_COUNT)
		if level == next_level:
			return
		level = next_level
		queue_redraw()

var selected := false:
	set(value):
		if selected == value:
			return
		selected = value
		queue_redraw()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	focus_mode = Control.FOCUS_NONE
	resized.connect(queue_redraw)
	queue_redraw()

func _gui_input(event: InputEvent) -> void:
	var mouse := event as InputEventMouseButton
	if mouse == null or mouse.button_index != MOUSE_BUTTON_LEFT or not mouse.pressed:
		return

	activated.emit()
	var next_level := _level_for_x(mouse.position.x)
	if next_level != level:
		level = next_level
		level_changed.emit(level)
	accept_event()

func _level_for_x(x: float) -> int:
	var usable_width := maxf(1.0, size.x - TICK_WIDTH)
	var ratio := clampf(x / usable_width, 0.0, 1.0)
	return clampi(roundi(ratio * STEP_COUNT), 0, STEP_COUNT)

func _draw() -> void:
	var usable_width := maxf(1.0, size.x - TICK_WIDTH)
	var center_y := roundf(size.y * 0.5)
	var track_thickness := float(get_theme_constant("track_thickness"))
	var tick_height := float(get_theme_constant("tick_height"))
	var selected_boost := float(get_theme_constant("selected_alpha_boost")) if selected else 0.0

	var track_inactive := get_theme_color("track_inactive")
	var tick_inactive := get_theme_color("tick_inactive")
	if selected:
		track_inactive.a = minf(1.0, track_inactive.a + selected_boost)
		tick_inactive.a = minf(1.0, tick_inactive.a + selected_boost)

	var track_active := get_theme_color("track_active")
	var tick_active := get_theme_color("tick_active")
	if selected:
		track_active.a = minf(1.0, track_active.a + selected_boost)
		tick_active.a = minf(1.0, tick_active.a + selected_boost)
	var active_x := roundf((float(level) / float(STEP_COUNT)) * usable_width)

	draw_rect(Rect2(0.0, center_y, usable_width, track_thickness), track_inactive)
	if level > 0:
		draw_rect(Rect2(0.0, center_y, active_x, track_thickness), track_active)

	var tick_top := roundf(center_y - tick_height * 0.5)
	for step in range(1, STEP_COUNT + 1):
		var tick_x := roundf((float(step) / float(STEP_COUNT)) * usable_width)
		var tick_color := tick_active if step <= level else tick_inactive
		draw_rect(Rect2(tick_x, tick_top, TICK_WIDTH, tick_height), tick_color)
