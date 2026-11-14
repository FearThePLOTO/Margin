extends Node
## Session state shared across features. Read it anywhere via GameState.<x>.
## Only put cross-feature data here; per-feature data stays in its feature folder.

enum Phase { HUB, LOADOUT, MISSION, DEBRIEF }

var phase: int = Phase.HUB
var objective_id: StringName = &""
var budget_used_usd: float = 0.0
var loadout: Array[StringName] = []
## Level being played (Book of Books keys); set by each level's root script.
var level_id := ""
## Results waiting to be shown (set by the level exit, read by main.gd).
var pending_results: Dictionary = {}

# --- Junior Astronaut Mission Trainer: the suit power budget -----------------
## The suit battery starts with START_CELLS cells to split between three
## systems; every power station adds one more (the player picks where it goes).
## Every cell placed somewhere is a cell missing elsewhere: no free choice.
const START_CELLS := 3
const MAX_PER_SYSTEM := 3
var power_cells := START_CELLS
var stations_charged: Array[String] = []   # stations that already gave their cell
var power_plan := {"o2": 1, "shield": 1, "light": 1}

# --- mission log (read by the mission report) --------------------------------
var plan_history: Array[Dictionary] = []   # {"station", "plan", "storm"}
var scrolls: Array[String] = []            # chapter ids of scrolls found this run
var deaths := {}                           # cause -> count
var tanks_taken := 0
var peak_radiation := 0.0
var mission_time_s := 0.0


# --- CONTINUE: the last checkpoint of an unfinished level ---------------------
const RUN_SAVE := "user://run_save.json"
## Set by main.gd only while a continued level is being built; levels read it
## in _ready (lander skips its landing, autostart cutscenes skip themselves).
var resume_point := Vector2.INF


func _ready() -> void:
	EventBus.checkpoint_reached.connect(_on_checkpoint)


func is_resuming() -> bool:
	return resume_point != Vector2.INF


func has_run_save() -> bool:
	return FileAccess.file_exists(RUN_SAVE)


func clear_run_save() -> void:
	if has_run_save():
		DirAccess.remove_absolute(ProjectSettings.globalize_path(RUN_SAVE))


func _on_checkpoint(pos: Vector2) -> void:
	if phase != Phase.MISSION or level_id.is_empty():
		return
	var f := FileAccess.open(RUN_SAVE, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({
			"level_id": level_id, "x": pos.x, "y": pos.y, "scrolls": scrolls,
			"deaths": deaths, "power_plan": power_plan, "time": mission_time_s,
			"cells": power_cells, "stations": stations_charged,
		}))


## Restores the saved run (stats + plan). Returns the checkpoint, or INF.
func load_run_save() -> Vector2:
	if not has_run_save():
		return Vector2.INF
	var d: Variant = JSON.parse_string(FileAccess.get_file_as_string(RUN_SAVE))
	if not d is Dictionary:
		return Vector2.INF
	scrolls.clear()
	for c: Variant in d.get("scrolls", []):
		scrolls.append(str(c))
	deaths = d.get("deaths", {})
	var plan: Variant = d.get("power_plan", {})
	if plan is Dictionary and not plan.is_empty():
		power_plan = {"o2": int(plan.get("o2", 1)), "shield": int(plan.get("shield", 1)), "light": int(plan.get("light", 1))}
	mission_time_s = float(d.get("time", 0.0))
	power_cells = int(d.get("cells", START_CELLS))
	stations_charged.clear()
	for st: Variant in d.get("stations", []):
		stations_charged.append(str(st))
	return Vector2(float(d.get("x", 0.0)), float(d.get("y", 0.0)))


func reset_mission() -> void:
	power_plan = {"o2": 1, "shield": 1, "light": 1}
	power_cells = START_CELLS
	stations_charged.clear()
	plan_history.clear()
	scrolls.clear()
	deaths.clear()
	tanks_taken = 0
	peak_radiation = 0.0
	mission_time_s = 0.0


func total_deaths() -> int:
	var n := 0
	for k: StringName in deaths:
		n += int(deaths[k])
	return n


func log_death(cause: StringName) -> void:
	deaths[cause] = int(deaths.get(cause, 0)) + 1
