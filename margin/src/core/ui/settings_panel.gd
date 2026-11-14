extends Control
## OPTIONS panel (main menu and pause menu): music / sound volume, fullscreen,
## optional NASA DATA sources. LEFT/RIGHT changes a value, ENTER also changes
## it (or opens the row), ESC goes back. Values live in the Settings autoload.

signal closed
signal data_requested

@export var show_data := true

@onready var _menu: PixelMenu = %OptionsMenu

var _rows: Array[StringName] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	_menu.active = false
	_menu.adjusted.connect(_on_adjusted)
	_menu.chosen.connect(_on_chosen)


func open() -> void:
	_rows = [&"music", &"sound", &"fullscreen"]
	if show_data:
		_rows.append(&"data")
	_rows.append(&"back")
	var texts := PackedStringArray()
	for r in _rows:
		texts.append(_text(r))
	_menu.options = texts
	_menu.selected = 0
	show()
	_menu.active = true
	_menu.queue_redraw()


func close() -> void:
	if not visible:
		return
	_menu.active = false
	hide()
	closed.emit()


func _text(row: StringName) -> String:
	match row:
		&"music": return "MUSIC  < %s >" % _vol(Settings.music)
		&"sound": return "SOUND  < %s >" % _vol(Settings.sound)
		&"fullscreen": return "FULLSCREEN  < %s >" % ("ON" if Settings.fullscreen else "OFF")
		&"data": return "NASA DATA SOURCES"
	return "BACK"


func _vol(v: int) -> String:
	return "OFF" if v == 0 else str(v)


func _on_adjusted(i: int, dir: int) -> void:
	match _rows[i]:
		&"music": Settings.set_value(&"music", Settings.music + dir)
		&"sound": Settings.set_value(&"sound", Settings.sound + dir)
		&"fullscreen": Settings.set_value(&"fullscreen", not Settings.fullscreen)
		_: return
	_menu.set_option_text(i, _text(_rows[i]))


func _on_chosen(i: int) -> void:
	match _rows[i]:
		&"music": Settings.set_value(&"music", (Settings.music + 1) % (Settings.MAX_LEVEL + 1))
		&"sound": Settings.set_value(&"sound", (Settings.sound + 1) % (Settings.MAX_LEVEL + 1))
		&"fullscreen": Settings.set_value(&"fullscreen", not Settings.fullscreen)
		&"data":
			data_requested.emit()
			return
		&"back":
			close()
			return
	_menu.set_option_text(i, _text(_rows[i]))


func _input(event: InputEvent) -> void:
	if visible and _menu.active and event.is_action_pressed(&"ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
