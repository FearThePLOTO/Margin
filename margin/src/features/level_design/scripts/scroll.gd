extends Area2D
## Book of Books scroll. Picking it up unlocks `chapter_id` in the Book of
## Books (saved) and shows "A new chapter is unlocked" on screen. Set
## `chapter_id` per instance (ids live in src/core/autoload/book_of_books.gd).
## Hide them well: one obvious, one behind a challenge, one tucked away.

@export var chapter_id := "l1_red_planet"
## First scroll of the game: the card also explains what the book is.
@export var first_scroll := false

var _taken := false

@onready var _sprite: Sprite2D = $Sprite


func _ready() -> void:
	add_to_group(&"scroll")
	body_entered.connect(_on_body_entered)
	if GameState.scrolls.has(chapter_id):   # already found in this run (CONTINUE)
		_taken = true
		monitoring = false
		hide()
		return
	var tw := create_tween().set_loops()
	tw.tween_property(_sprite, "position:y", -2.0, 0.7).set_trans(Tween.TRANS_SINE)
	tw.tween_property(_sprite, "position:y", 1.0, 0.7).set_trans(Tween.TRANS_SINE)


func _on_body_entered(body: Node2D) -> void:
	if _taken or not body.is_in_group(&"player"):
		return
	_taken = true
	GameState.scrolls.append(chapter_id)
	var ch := BookOfBooks.unlock(chapter_id).duplicate()
	ch["first"] = first_scroll
	set_deferred("monitoring", false)
	var tw := create_tween().set_parallel(true)
	tw.tween_property(_sprite, "position:y", -14.0, 0.35)
	tw.tween_property(self, "modulate:a", 0.0, 0.35)
	EventBus.scroll_collected.emit(ch)
