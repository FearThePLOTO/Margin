extends Control
## The Book of Books: a pixel-art book that slides up and turns its pages.
##  Spread 0 of a level: "LEVEL 1 : THE CAVE", times died, scrolls found.
##  ENTER: read the scrolls, one per spread (locked ones show ???).
##  LEFT/RIGHT: turn pages (on the level spread: change level).
##  B or ESC: back to the level spread, then close.
## Data: BookOfBooks autoload. Opened by the pause menu, B in game, the main
## menu and the results screen.

signal closed

const SCROLL_TEX := preload("res://src/assets/char/scroll.png")
const INK := Color(0.24, 0.15, 0.1)
const RED := Color(0.62, 0.2, 0.12)
const DIM := Color(0.45, 0.35, 0.25)

var _level := 0      # index in BookOfBooks.LEVELS
var _page := 0       # 0 = level spread, 1..n = scroll n
var _busy := false

@onready var _dim: ColorRect = $Dim
@onready var _book: Control = $BookRoot
@onready var _l_top: Label = %LeftTop
@onready var _l_title: Label = %LeftTitle
@onready var _l_icon: TextureRect = %LeftIcon
@onready var _l_text: Label = %LeftText
@onready var _l_source: Label = %LeftSource
@onready var _r_text: Label = %RightText
@onready var _r_icons: HBoxContainer = %RightIcons
@onready var _r_foot: Label = %RightFoot
@onready var _flip: TextureRect = %Flip
@onready var _home_y: float = _book.position.y


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()
	_flip.hide()


func open(level_id := "", chapter_id := "") -> void:
	_level = 0
	for i in BookOfBooks.LEVELS.size():
		if BookOfBooks.LEVELS[i].id == (level_id if level_id != "" else GameState.level_id):
			_level = i
	_page = 0
	if chapter_id != "":
		var chs: Array = BookOfBooks.LEVELS[_level].chapters
		for i in chs.size():
			if chs[i].id == chapter_id:
				_page = i + 1
	_render()
	show()
	_dim.modulate.a = 0.0
	_book.position.y = _home_y + 200.0
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_dim, "modulate:a", 1.0, 0.25)
	tw.tween_property(_book, "position:y", _home_y, 0.4).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)


func close() -> void:
	if not visible or _busy:
		return
	_busy = true
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_dim, "modulate:a", 0.0, 0.2)
	tw.tween_property(_book, "position:y", _home_y + 200.0, 0.25).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await tw.finished
	hide()
	_busy = false
	closed.emit()


# --------------------------------------------------------------- pages ---

func _render() -> void:
	var lvl: Dictionary = BookOfBooks.LEVELS[_level]
	var chs: Array = lvl.chapters
	for c in _r_icons.get_children():
		c.queue_free()
	_l_icon.modulate = Color.WHITE
	_l_source.text = ""
	_l_title.add_theme_font_size_override(&"font_size", 16 if _page == 0 else 8)
	if _page == 0:
		_l_top.text = "LEVEL %d" % lvl.number
		_l_title.text = lvl.name
		_l_icon.texture = SCROLL_TEX
		var r: Dictionary = BookOfBooks.level_results.get(lvl.id, {})
		if chs.is_empty():
			_l_text.text = "A new adventure is on its way..."
			_r_text.text = "Finish Level %d to open this chapter." % (lvl.number - 1)
			_r_foot.text = "LEFT: back"
			return
		var got := BookOfBooks.chapters_unlocked_in(lvl.id)
		_l_text.text = "Find the hidden scrolls to fill these pages!"
		var lines := "TIMES DIED: %d\n\nSCROLLS: %d / %d" % [int(r.get("deaths", 0)), got, chs.size()]
		if r.get("completed", false):
			lines += "\n\n\n\nBEST RUN: %d deaths" % int(r.get("best_deaths", 0))
		_r_text.text = lines
		for i in chs.size():
			var ic := TextureRect.new()
			ic.texture = SCROLL_TEX
			ic.stretch_mode = TextureRect.STRETCH_KEEP_CENTERED
			ic.modulate = Color.WHITE if BookOfBooks.is_unlocked(chs[i].id) else Color(0.4, 0.35, 0.3, 0.5)
			_r_icons.add_child(ic)
		_r_foot.text = "ENTER: read scrolls" if got > 0 else "LEFT/RIGHT: levels"
		return
	var ch: Dictionary = chs[_page - 1]
	_l_top.text = "SCROLL %d" % _page
	_l_icon.texture = SCROLL_TEX
	if BookOfBooks.is_unlocked(ch.id):
		_l_title.text = ch.title
		_l_text.text = ch.intro
		_r_text.text = ch.body
		_l_source.text = "Source: " + ch.source
	else:
		_l_title.text = "???"
		_l_icon.modulate = Color(0.4, 0.35, 0.3, 0.5)
		_l_text.text = "This page is still blank."
		_r_text.text = "Find this scroll in Level %d to read it!" % lvl.number
	_r_foot.text = "%d / %d" % [_page, chs.size()]


func _turn(dir: int, change_level := false) -> void:
	if _busy:
		return
	var chs: Array = BookOfBooks.LEVELS[_level].chapters
	if change_level:
		var nl := clampi(_level + dir, 0, BookOfBooks.LEVELS.size() - 1)
		if nl == _level:
			return
		_level = nl
		_page = 0
	else:
		var np := clampi(_page + dir, 0, chs.size())
		if np == _page:
			return
		_page = np
	_busy = true
	# page sweep: a blank page folds over from the spine to reveal the new spread
	_flip.position = Vector2(152 if dir > 0 else 11, 8)
	_flip.pivot_offset = Vector2(0 if dir > 0 else _flip.size.x, 0)
	_flip.scale = Vector2.ONE
	_flip.show()
	_render()
	var tw := create_tween()
	tw.tween_property(_flip, "scale:x", 0.0, 0.22).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await tw.finished
	_flip.hide()
	_busy = false


func _input(event: InputEvent) -> void:
	if not visible or _busy:
		return
	var chs: Array = BookOfBooks.LEVELS[_level].chapters
	if event.is_action_pressed(&"ui_cancel") or event.is_action_pressed(&"open_book"):
		if _page > 0:
			_turn(-_page)
		else:
			close()
	elif event.is_action_pressed(&"ui_accept"):
		if _page == 0 and not chs.is_empty():
			_turn(1)
		elif _page > 0 and _page < chs.size():
			_turn(1)
		elif _page == chs.size():
			_turn(-_page)
	elif event.is_action_pressed(&"ui_right") or event.is_action_pressed(&"move_right"):
		_turn(1, _page == 0)
	elif event.is_action_pressed(&"ui_left") or event.is_action_pressed(&"move_left"):
		_turn(-1, _page == 0)
	else:
		return
	get_viewport().set_input_as_handled()
