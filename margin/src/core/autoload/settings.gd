extends Node
## Player settings: music / sound volume (0..10) and fullscreen.
## Applied to the audio buses and window at startup, saved to user://settings.cfg.

const PATH := "user://settings.cfg"
const MAX_LEVEL := 10

var music := 7
var sound := 8
var fullscreen := false


func _ready() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) == OK:
		music = int(cfg.get_value("audio", "music", music))
		sound = int(cfg.get_value("audio", "sound", sound))
		fullscreen = bool(cfg.get_value("video", "fullscreen", fullscreen))
	apply()


func set_value(key: StringName, value: Variant) -> void:
	match key:
		&"music": music = clampi(int(value), 0, MAX_LEVEL)
		&"sound": sound = clampi(int(value), 0, MAX_LEVEL)
		&"fullscreen": fullscreen = bool(value)
	apply()
	save()


func apply() -> void:
	_bus(&"Music", music)
	_bus(&"SFX", sound)
	if not Engine.is_editor_hint() and DisplayServer.get_name() != "headless":
		var mode := DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen else DisplayServer.WINDOW_MODE_WINDOWED
		if DisplayServer.window_get_mode() != mode:
			DisplayServer.window_set_mode(mode)


func save() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "music", music)
	cfg.set_value("audio", "sound", sound)
	cfg.set_value("video", "fullscreen", fullscreen)
	cfg.save(PATH)


func _bus(bus_name: StringName, level: int) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	if idx < 0:
		return
	AudioServer.set_bus_mute(idx, level == 0)
	AudioServer.set_bus_volume_db(idx, linear_to_db(level / float(MAX_LEVEL)))
