extends Node
## The Book of Books.
##  - Chapters: every level hides scrolls; each scroll unlocks one chapter of
##    real space science (sources cited). Level 1 has 3.
##  - Results: best deaths / scrolls per level, shown in the book.
##  - Notes: mission-failure notes (Player.fail in non-training levels).
## Progress is saved to user://book_of_books.json so the book persists.

signal note_added(note: Dictionary)
signal chapter_unlocked(chapter: Dictionary)

const SAVE_PATH := "user://book_of_books.json"

## Level id -> book section. Each chapter fills one book spread:
## `intro` on the left page (under the title), `body` + `source` on the right.
const LEVELS := [
	{
		"id": "level_01", "number": 1, "name": "THE CAVE",
		"chapters": [
			{
				"id": "l1_red_planet", "title": "The Red Planet",
				"intro": "Mars is the 4th planet from the Sun. Its dust is full of rusty iron, so the planet looks red!",
				"body": "The air is thin and nobody can breathe it. Gravity is 38% of Earth's: you jump way higher!\n\nA Mars day (a sol) lasts 24 h 39 min. Mars has two moons: Phobos and Deimos.",
				"source": "NASA Mars facts",
			},
			{
				"id": "l1_solar_storms", "title": "Solar Storms",
				"intro": "Sometimes the Sun blasts out flares. Fast particles from them make a solar radiation storm.",
				"body": "Earth's thick air protects us. Mars has almost none, so astronauts hide behind rock.\n\nNASA's DONKI records every storm. Curiosity measured 0.67 mSv of radiation a day on Mars.",
				"source": "NASA DONKI; Curiosity RAD 2014",
			},
			{
				"id": "l1_living_in_space", "title": "Living in Space",
				"intro": "An astronaut breathes about 0.8 kg of oxygen a day. Machines make that air, and they need power.",
				"body": "Low gravity makes bones weaker, about 1% a month, so astronauts exercise 2 hours a day.\n\nThey grew lettuce in space! Air, food, light and shields share one power supply.",
				"source": "NASA BVAD, HRP, Veggie",
			},
		],
	},
	{"id": "level_02", "number": 2, "name": "COMING SOON", "chapters": []},
]

var notes: Array[Dictionary] = []
var unlocked := {}        # chapter_id -> true
var level_results := {}   # level_id -> {"deaths", "best_deaths", "best_scrolls", "completed"}


func _ready() -> void:
	_load()
	EventBus.player_died.connect(_on_player_died)


## Every death counts in the book ("how many times you died in this level").
func _on_player_died() -> void:
	if GameState.level_id.is_empty():
		return
	var r: Dictionary = level_results.get(GameState.level_id, {})
	r["deaths"] = int(r.get("deaths", 0)) + 1
	level_results[GameState.level_id] = r
	_save()


# ---------------------------------------------------------------- notes ---

func add_note(entry_id: StringName, reason: String, data: Dictionary = {}) -> void:
	var note := {"entry_id": entry_id, "reason": reason, "data": data}
	notes.append(note)
	note_added.emit(note)


func get_notes() -> Array[Dictionary]:
	return notes


# ------------------------------------------------------------- chapters ---

func get_chapter(chapter_id: String) -> Dictionary:
	for lvl: Dictionary in LEVELS:
		for ch: Dictionary in lvl.chapters:
			if ch.id == chapter_id:
				return ch
	return {}


func get_level(level_id: String) -> Dictionary:
	for lvl: Dictionary in LEVELS:
		if lvl.id == level_id:
			return lvl
	return {}


func is_unlocked(chapter_id: String) -> bool:
	return unlocked.has(chapter_id)


## Unlocks a chapter (saved). Returns the chapter dictionary.
func unlock(chapter_id: String) -> Dictionary:
	var ch := get_chapter(chapter_id)
	if ch.is_empty():
		push_warning("Book of Books: unknown chapter %s" % chapter_id)
		return ch
	unlocked[chapter_id] = true
	_save()
	chapter_unlocked.emit(ch)
	return ch


func chapters_unlocked_in(level_id: String) -> int:
	var n := 0
	for ch: Dictionary in get_level(level_id).get("chapters", []):
		if is_unlocked(ch.id):
			n += 1
	return n


# -------------------------------------------------------------- results ---

func record_level(level_id: String, deaths: int, scrolls: int) -> void:
	var r: Dictionary = level_results.get(level_id, {})
	r["best_deaths"] = mini(int(r.get("best_deaths", deaths)), deaths)
	r["best_scrolls"] = maxi(int(r.get("best_scrolls", 0)), scrolls)
	r["completed"] = true
	level_results[level_id] = r
	_save()


## START NEW GAME wipes the book: every scroll has to be found again.
func reset_progress() -> void:
	unlocked.clear()
	level_results.clear()
	_save()


func has_progress() -> bool:
	return not unlocked.is_empty() or not level_results.is_empty()


# --------------------------------------------------------------- saving ---

func _save() -> void:
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({"unlocked": unlocked.keys(), "results": level_results}))


func _load() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var data: Variant = JSON.parse_string(FileAccess.get_file_as_string(SAVE_PATH))
	if data is Dictionary:
		for id: Variant in data.get("unlocked", []):
			unlocked[str(id)] = true
		var res: Variant = data.get("results", {})
		if res is Dictionary:
			level_results = res
