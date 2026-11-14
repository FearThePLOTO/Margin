class_name PixelMenu
extends VBoxContainer
## Kid-readable menu list used by the main menu, settings and pause screens.
## Fill `options` in the inspector; each becomes a big shadowed label.
##  UP/DOWN (or W/S) moves, ENTER/SPACE chooses, LEFT/RIGHT emits `adjusted`
##  (settings rows), mouse hover selects, click chooses.
## The selected row turns orange, slides right and gets a bobbing arrow.
## Only reacts while visible and `active`.

signal chosen(index: int)
signal adjusted(index: int, dir: int)
signal moved(index: int)

@export var options: PackedStringArray = []:
	set(v):
		options = v
		if is_node_ready():
			_build()
@export var font_size := 8
@export var active := true
@export var centered := true
@export var color_idle := Color(0.92, 0.88, 0.82)
@export var color_selected := Color(1.0, 0.69, 0.23)
@export var color_disabled := Color(0.48, 0.42, 0.42)

const INK := Color(0.1, 0.06, 0.12)
const SLIDE_PX := 4.0

var selected := 0:
	set(v):
		selected = v
		if is_node_ready():
			_refresh(false)
var _disabled := {}   # index -> true (greyed out, skipped by the cursor)
var _labels: Array[Label] = []
var _t := 0.0
var _blip: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	add_theme_constant_override(&"separation", 3)
	_blip = AudioStreamPlayer.new()
	_blip.stream = preload("res://src/features/audio/sfx/mc_voice.wav")
	_blip.bus = &"SFX"
	_blip.pitch_scale = 1.6
	_blip.volume_db = -8.0
	add_child(_blip)
	_build()


func _build() -> void:
	for l in _labels:
		l.queue_free()
	_labels.clear()
	for i in options.size():
		var l := Label.new()
		l.text = options[i]
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER if centered else HORIZONTAL_ALIGNMENT_LEFT
		l.add_theme_font_size_override(&"font_size", font_size)
		l.add_theme_color_override(&"font_shadow_color", INK)
		l.add_theme_constant_override(&"shadow_offset_x", 1)
		l.add_theme_constant_override(&"shadow_offset_y", 1)
		l.add_theme_color_override(&"font_outline_color", INK)
		l.add_theme_constant_override(&"outline_size", 2)
		l.mouse_filter = Control.MOUSE_FILTER_STOP
		l.mouse_entered.connect(_on_hover.bind(i))
		l.gui_input.connect(_on_label_input.bind(i))
		add_child(l)
		_labels.append(l)
	selected = clampi(selected, 0, maxi(0, options.size() - 1))
	_refresh(false)


func set_option_text(index: int, text: String) -> void:
	if index >= 0 and index < _labels.size():
		options[index] = text
		_labels[index].text = text


func set_disabled(index: int, off: bool) -> void:
	if off:
		_disabled[index] = true
	else:
		_disabled.erase(index)
	if off and index == selected:
		select(_step(selected, 1), false)
	_refresh(false)


func is_disabled(index: int) -> bool:
	return _disabled.has(index)


## Next enabled index from `from` in direction `dir` (wraps).
func _step(from: int, dir: int) -> int:
	var i := from
	for k in options.size():
		i = posmod(i + dir, options.size())
		if not _disabled.has(i):
			return i
	return from


func select(index: int, sound := true) -> void:
	index = clampi(index, 0, options.size() - 1)
	if index == selected or _disabled.has(index):
		return
	selected = index
	if sound and is_visible_in_tree():
		_blip.play()
	_refresh(true)
	moved.emit(selected)


func _refresh(animate: bool) -> void:
	for i in _labels.size():
		var l := _labels[i]
		var on := i == selected
		var col := color_selected if on else color_idle
		if _disabled.has(i):
			col = color_disabled
		l.add_theme_color_override(&"font_color", col)
		var target := SLIDE_PX if on and not centered else 0.0
		if animate:
			create_tween().tween_property(l, "position:x", target, 0.08)
	queue_redraw()


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	_t += delta
	queue_redraw()


## Bobbing arrow(s) beside the selected row (two facing arrows when centered).
func _draw() -> void:
	if _labels.is_empty() or not active:
		return
	var l := _labels[selected]
	var bob := roundf(sin(_t * 8.0) * 1.0)
	var cy := l.position.y + l.size.y * 0.5
	var text_w := l.get_theme_font(&"font").get_string_size(l.text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
	var left_x := (l.size.x - text_w) * 0.5 - 7.0 if centered else -5.0
	_arrow(Vector2(left_x + bob, cy), 1)
	if centered:
		_arrow(Vector2((l.size.x + text_w) * 0.5 + 6.0 - bob, cy), -1)


func _arrow(at: Vector2, dir: int) -> void:
	var pts := PackedVector2Array([at + Vector2(-2 * dir, -3), at + Vector2(2 * dir, 0), at + Vector2(-2 * dir, 3)])
	var shadow := PackedVector2Array()
	for p in pts:
		shadow.append(p + Vector2(1, 1))
	draw_colored_polygon(shadow, INK)
	draw_colored_polygon(pts, color_selected)


func _on_hover(i: int) -> void:
	if active:
		select(i)


func _on_label_input(event: InputEvent, i: int) -> void:
	if not active:
		return
	var mb := event as InputEventMouseButton
	if mb and mb.pressed and mb.button_index == MOUSE_BUTTON_LEFT and not _disabled.has(i):
		select(i, false)
		chosen.emit(i)
		accept_event()


func _input(event: InputEvent) -> void:
	if not active or not is_visible_in_tree() or options.is_empty():
		return
	if _pressed(event, [&"ui_up", &"move_up"]):
		select(_step(selected, -1))
	elif _pressed(event, [&"ui_down", &"move_down"]):
		select(_step(selected, 1))
	elif _pressed(event, [&"ui_left", &"move_left"]):
		adjusted.emit(selected, -1)
	elif _pressed(event, [&"ui_right", &"move_right"]):
		adjusted.emit(selected, 1)
	elif event.is_action_pressed(&"ui_accept"):
		if not _disabled.has(selected):
			chosen.emit(selected)
	else:
		return
	get_viewport().set_input_as_handled()


func _pressed(event: InputEvent, actions: Array) -> bool:
	for a: StringName in actions:
		if InputMap.has_action(a) and event.is_action_pressed(a, true):
			return true
	return false
