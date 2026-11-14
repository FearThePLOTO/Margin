extends CanvasLayer
## Mars surface weather: gusty wind blowing dust across the screen, with a
## faint sandy haze. Screen-space (CanvasLayer), so it follows the camera.
## Fades out inside any `Cave` zone. A cutscene can call intensify() when the
## solar storm alert hits (cutscene_trigger.activate_after).

@export var gust_strength := 1.0
@export var haze_color := Color(0.95, 0.68, 0.42, 0.06)

var _t := 0.0
var _fade := 1.0
var _target_fade := 1.0

@onready var _dust: CPUParticles2D = $Dust
@onready var _streaks: CPUParticles2D = $Streaks
@onready var _haze: ColorRect = $Haze


func _ready() -> void:
	EventBus.hazard_entered.connect(_on_entered)
	EventBus.hazard_exited.connect(_on_exited)


func _process(delta: float) -> void:
	_t += delta
	_fade = move_toward(_fade, _target_fade, delta * 1.5)
	# slow swell + sharp random-ish gusts
	var gust := 0.65 + 0.3 * sin(_t * 0.6) + 0.45 * maxf(0.0, sin(_t * 1.9 + 2.0 * sin(_t * 0.37)))
	gust *= gust_strength
	_dust.speed_scale = gust
	_streaks.speed_scale = gust
	_dust.modulate.a = _fade
	_streaks.modulate.a = _fade
	var c := haze_color
	c.a = haze_color.a * (0.6 + 0.6 * gust) * _fade
	_haze.color = c


## The storm arrives: stronger wind, thicker reddish haze.
func intensify() -> void:
	create_tween().tween_property(self, "gust_strength", 1.7, 1.5)
	haze_color = Color(0.9, 0.42, 0.25, 0.12)
	_dust.amount = 180


func _on_entered(zone_id: StringName) -> void:
	if zone_id == &"Cave":
		_target_fade = 0.0


func _on_exited(zone_id: StringName) -> void:
	if zone_id == &"Cave":
		_target_fade = 1.0
