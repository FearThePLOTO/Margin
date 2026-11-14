extends Control
## Level results: deaths, scrolls found (shown as scroll icons), time, and
## the Book of Books chapters this run unlocked. The same numbers are saved in
## the Book of Books (main.gd calls BookOfBooks.record_level before showing this).

signal back_requested

const SCROLL_TEX := preload("res://src/assets/char/scroll.png")

@onready var _title: Label = %LevelTitle
@onready var _deaths: Label = %DeathsValue
@onready var _scroll_icons: HBoxContainer = %ScrollIcons
@onready var _scroll_count: Label = %ScrollCount
@onready var _time: Label = %TimeValue
@onready var _found: Label = %FoundText
@onready var _storm: Label = %StormText
@onready var _book_button: Button = %BookButton
@onready var _menu_button: Button = %MenuButton
@onready var _book = %BookScreen  # book_screen.gd


func _ready() -> void:
	Music.play(&"ui_music")
	_menu_button.pressed.connect(func() -> void: back_requested.emit())
	_book_button.pressed.connect(func() -> void: _book.open(_level_id))
	_book.closed.connect(_close_book)


func _close_book() -> void:
	_book_button.grab_focus()


var _level_id := "level_01"


func open(stats: Dictionary) -> void:
	_level_id = str(stats.get("level", "level_01"))
	var level: Dictionary = BookOfBooks.get_level(_level_id)
	var total := int(stats.get("scrolls_total", 3))
	var got := GameState.scrolls.size()
	var t := int(GameState.mission_time_s)
	_title.text = "LEVEL %d COMPLETE!" % int(level.get("number", 1))
	_deaths.text = str(GameState.total_deaths())
	_scroll_count.text = "%d/%d" % [got, total]
	_time.text = "%d:%02d" % [t / 60, t % 60]
	for c in _scroll_icons.get_children():
		c.queue_free()
	for i in total:
		var icon := TextureRect.new()
		icon.texture = SCROLL_TEX
		icon.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
		icon.modulate = Color.WHITE if i < got else Color(0.2, 0.2, 0.25, 0.8)
		_scroll_icons.add_child(icon)
	if got == 0:
		_found.text = "No scrolls this time. They hide in secret places!"
	else:
		var names: PackedStringArray = []
		for id in GameState.scrolls:
			names.append(str(BookOfBooks.get_chapter(id).get("title", id)))
		_found.text = "New in the Book of Books: " + ", ".join(names)
	var w := SpaceWeather.info
	_storm.text = "Storm: %s, real NASA DONKI data (%s)" % [w.get("level", "?"), w.get("date", "?")]
	_menu_button.grab_focus.call_deferred()
