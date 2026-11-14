extends Control
## Animated Mars dust storm (main menu background), after the proposal's opening
## slide 5, but denser: night dust sky, two billowing cloud layers, fast dust
## dashes, ~170 wind streaks with motion tails, slow swirls, the odd lightning
## flash, warm wash and a dark vignette. Layers come from tools/uigen/gen_storm.py.
## `band_y` / `band_alpha`: a dark horizontal band that keeps text readable
## (tweened by the main menu as the logo moves).

const BASE := preload("res://src/assets/ui/storm/storm_base.png")
const CLOUD := preload("res://src/assets/ui/storm/storm_cloud.png")
const DASH_A := preload("res://src/assets/ui/storm/storm_dash_a.png")
const DASH_B := preload("res://src/assets/ui/storm/storm_dash_b.png")
const VIGNETTE := preload("res://src/assets/ui/storm/storm_vignette.png")
const STREAK_COLORS := [Color("#e0a074"), Color("#b7410e"), Color("#c9707a"), Color("#7a2e1b")]
const SIZE := Vector2(320, 180)

@export var streak_count := 170
@export var wind_speed := 1.0
@export var lightning := true
@export var band_y := 80.0
@export var band_alpha := 0.45
@export var band_half_height := 40.0

var _t := 0.0
var _streaks: Array[Dictionary] = []
var _bolt: PackedVector2Array
var _bolt_branch: PackedVector2Array
var _flash := 0.0
var _next_bolt := 3.5


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	texture_repeat = CanvasItem.TEXTURE_REPEAT_ENABLED
	var rng := RandomNumberGenerator.new()
	rng.seed = 3
	for i in streak_count:
		_streaks.append({
			"x": rng.randf() * SIZE.x, "y": float(rng.randi_range(0, int(SIZE.y) - 1)),
			"len": (3 + rng.randi_range(0, 13)) * 1.5, "v": 200.0 + rng.randf() * 470.0,
			"c": STREAK_COLORS[rng.randi_range(0, 3)], "thick": 2.0 if rng.randf() < 0.12 else 1.0,
		})


func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return
	_t += delta * wind_speed
	_flash = maxf(0.0, _flash - delta * 3.0)
	if lightning:
		_next_bolt -= delta
		if _next_bolt <= 0.0:
			_make_bolt()
			_next_bolt = randf_range(5.0, 10.0)
	queue_redraw()


func _make_bolt() -> void:
	_flash = 0.5
	_bolt = PackedVector2Array()
	var x := randf_range(30.0, SIZE.x - 30.0)
	var y := 0.0
	while y < SIZE.y * 0.75:
		_bolt.append(Vector2(roundf(x), roundf(y)))
		y += randf_range(5.0, 11.0)
		x += randf_range(-7.0, 7.0)
	_bolt_branch = PackedVector2Array()
	if _bolt.size() > 4:
		var b := _bolt[3]
		var dir := -1.0 if randf() < 0.5 else 1.0
		for k in 5:
			_bolt_branch.append(b)
			b += Vector2(dir * randf_range(3.0, 7.0), randf_range(4.0, 8.0))


func _draw() -> void:
	draw_texture(BASE, Vector2.ZERO)
	# billowing dust clouds (tile horizontally)
	_scroll(CLOUD, -_t * 14.0, sin(_t * 0.6) * 4.0, Color(1, 1, 1, 0.85), false)
	_scroll(CLOUD, -_t * 30.0 + 90.0, sin(_t * 0.9) * 6.0, Color(1, 1, 1, 0.55), true)
	# fast airborne dust dashes
	_tile(DASH_A, -_t * 260.0, 0.0, Color(1, 1, 1, 0.20))
	_tile(DASH_B, -_t * 180.0, sin(_t * 0.9) * 6.0, Color(1, 1, 1, 0.22))
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0.08, 0.047, 0.07, 0.30))
	# lightning inside the storm
	if _flash > 0.25:
		_polyline(_bolt, Color("#8fa4ff"), 3.0)
		_polyline(_bolt_branch, Color("#8fa4ff"), 2.0)
		_polyline(_bolt, Color("#e8eeff"), 1.0)
		_polyline(_bolt_branch, Color.WHITE, 1.0)
	# wind streaks with motion tails
	for s: Dictionary in _streaks:
		var sx := roundf(fposmod(s.x - s.v * _t, SIZE.x + 40.0) - 20.0)
		var ln: float = s.len
		var c: Color = s.c
		draw_rect(Rect2(sx - ln, s.y, ln, s.thick), Color(c, 0.92))
		draw_rect(Rect2(sx, s.y, ln * 0.9, s.thick), Color(c, 0.4))
	# big slow swirls
	for i in 4:
		var cx := SIZE.x + 100.0 - fposmod(_t * 40.0 + i * 140.0, SIZE.x + 200.0)
		var cy := 40.0 + i * 38.0
		var rx := 40.0 - i * 6.0
		draw_set_transform(Vector2(roundf(cx), cy), 0.0, Vector2(1.0, (8.0 - i) / rx))
		draw_circle(Vector2.ZERO, rx, Color(0.63, 0.43, 0.35, 0.12))
		draw_circle(Vector2.ZERO, rx * 0.6, Color(0.63, 0.43, 0.35, 0.10))
	draw_set_transform(Vector2.ZERO)
	draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0.757, 0.408, 0.227, 0.12))
	# readability band behind the title / menu
	if band_alpha > 0.0:
		var steps := 10
		for k in steps:
			var f := float(k) / steps
			var h := band_half_height * (1.0 - f)
			draw_rect(Rect2(0, band_y - h, SIZE.x, h * 2.0), Color(0.047, 0.027, 0.024, band_alpha / steps * 1.6))
	draw_texture(VIGNETTE, Vector2.ZERO)
	if _flash > 0.0:
		draw_rect(Rect2(Vector2.ZERO, SIZE), Color(0.87, 0.91, 1.0, _flash * 0.5))


func _scroll(tex: Texture2D, ox: float, oy: float, mod: Color, flip: bool) -> void:
	var w := float(tex.get_width())
	var x := roundf(fposmod(ox, w)) - w
	var y := roundf(oy)
	if flip:
		draw_set_transform(Vector2(0, SIZE.y), 0.0, Vector2(1, -1))
	while x < SIZE.x:
		draw_texture(tex, Vector2(x, y), mod)
		x += w
	draw_set_transform(Vector2.ZERO)


func _tile(tex: Texture2D, ox: float, oy: float, mod: Color) -> void:
	var s := tex.get_size()
	var start := Vector2(roundf(fposmod(ox, s.x)) - s.x, roundf(fposmod(oy, s.y)) - s.y)
	draw_texture_rect(tex, Rect2(start, SIZE + s * 2.0), true, mod)


func _polyline(pts: PackedVector2Array, c: Color, w: float) -> void:
	if pts.size() >= 2:
		draw_polyline(pts, c, w)
