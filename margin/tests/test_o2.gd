extends Node
## Headless smoke tests for the O2 mechanic and mission HUD.
## Run from the project root (game mode, so the autoloads are registered):
##   godot --headless res://tests/test_o2.tscn
## Exits 0 when everything passes, 1 on any failure.
##
## Cave contract: the O2 bar is the ONLY thing that changes inside a cave —
## no separate hazard gauge. Empty tank inside the cave fails the mission.

var _failures := 0
var _checks := 0


func _ready() -> void:
	print("== Margin O2 / HUD smoke tests ==")
	_test_o2_starts_full()
	_test_o2_drain_is_a_function_of_time()
	_test_o2_does_not_refill_outside()
	_test_cave_with_o2_survives_then_fails_when_dry()
	_test_cave_without_o2_fails_on_entry()
	_test_tank_pickup_refills()
	_test_hud_bars_follow_gauges()
	_test_player_test_scene_loads()
	_print_summary()
	get_tree().quit(1 if _failures > 0 else 0)


# -------------------------------------------------------------- helpers ---

func _fresh_player() -> Player:
	GameState.loadout.clear()
	var p: Player = (load("res://src/features/mechanics/scenes/player.tscn") as PackedScene).instantiate()
	add_child(p)
	return p


func _check(cond: bool, what: String) -> void:
	_checks += 1
	if cond:
		print("  PASS  %s" % what)
	else:
		_failures += 1
		printerr("  FAIL  %s" % what)


func _print_summary() -> void:
	print("== %d checks, %d failures ==" % [_checks, _failures])


# --------------------------------------------------------------- tests ---

func _test_o2_starts_full() -> void:
	var p := _fresh_player()
	_check(is_equal_approx(p.o2.o2, 1.0), "O2 starts full")
	p.free()


func _test_o2_drain_is_a_function_of_time() -> void:
	var p := _fresh_player()
	EventBus.hazard_entered.emit(&"Cave")
	for i in 22:
		p.o2.process(1.0)
	_check(absf(p.o2.o2 - 0.5) < 0.02, "half the supply time -> half the tank (22.5 s target)")
	for i in 23:
		p.o2.process(1.0)
	_check(is_zero_approx(p.o2.o2), "45 s in the cave drains the tank")
	p.free()


func _test_o2_does_not_refill_outside() -> void:
	var p := _fresh_player()
	EventBus.hazard_entered.emit(&"Cave")
	for i in 22:
		p.o2.process(1.0)
	var drained := p.o2.o2
	EventBus.hazard_exited.emit(&"Cave")
	for i in 10:
		p.o2.process(1.0)
	_check(is_equal_approx(p.o2.o2, drained), "leaving the cave does NOT refill the supply")
	# Pickups are the only refill.
	p.o2.add_supply(GameConstants.O2_TANK_PICKUP)
	_check(p.o2.o2 > drained, "only tank pickups raise the supply")
	p.free()


func _test_cave_with_o2_survives_then_fails_when_dry() -> void:
	var p := _fresh_player()
	EventBus.hazard_entered.emit(&"Cave")
	for i in 44:
		p.o2.process(1.0)
	_check(not p.mission_over, "44 s in the cave with O2 stays alive")
	_check(p.o2.o2 > 0.0, "the tank is still not empty at 44 s")
	p.o2.process(1.0)
	_check(p.mission_over, "the moment the tank runs dry the mission fails")
	_check(BookOfBooks.notes.size() > 0, "the failure wrote a Book of Books note")
	_check(BookOfBooks.notes[-1].entry_id == &"book.life_support.o2", "the note id is book.life_support.o2")
	p.free()


func _test_cave_without_o2_fails_on_entry() -> void:
	var p := _fresh_player()
	GameState.loadout.assign([&"tool.jetpack", &"tool.tether", &"tool.spikes"])
	p.o2.process(1.0)
	_check(is_zero_approx(p.o2.o2), "without tool.o2 there is no supply (cleared on the first tick)")
	_check(not p.mission_over, "outside the cave the missing O2 costs nothing")
	EventBus.hazard_entered.emit(&"Cave")
	p.o2.process(1.0)
	_check(p.mission_over, "entering a cave with no O2 fails on the spot")
	p.free()


func _test_tank_pickup_refills() -> void:
	var p := _fresh_player()
	EventBus.hazard_entered.emit(&"Cave")
	for i in 30:
		p.o2.process(1.0)  # 30 s -> 2/3 drained, ~1/3 left
	var before := p.o2.o2
	p.o2.add_supply(GameConstants.O2_TANK_PICKUP)
	_check(absf(p.o2.o2 - (before + GameConstants.O2_TANK_PICKUP)) < 0.01,
			"one scattered tank adds a fixed 30% supply")
	p.o2.add_supply(1.0)
	_check(is_equal_approx(p.o2.o2, 1.0), "supply clamps at full")

	# Full pickup flow: the tank scene refills the player on contact.
	var tank: Area2D = (load("res://src/features/mechanics/scenes/o2_tank.tscn") as PackedScene).instantiate()
	add_child(tank)
	p.o2.process(10.0)  # drift the supply down again
	var before_pickup := p.o2.o2
	tank.body_entered.emit(p)
	_check(absf(p.o2.o2 - minf(before_pickup + GameConstants.O2_TANK_PICKUP, 1.0)) < 0.01,
			"touching the tank refills the supply")
	_check(tank.is_queued_for_deletion(), "tank consumed on pickup")
	tank.free()
	p.free()


func _test_hud_bars_follow_gauges() -> void:
	var hud: CanvasLayer = (load("res://src/features/ui/scenes/mission_hud.tscn") as PackedScene).instantiate()
	add_child(hud)
	EventBus.gauges_changed.emit({
		"heat": 25.0, "chill": 0.0, "radiation": 50.0, "o2": 0.5,
	})
	_check(is_equal_approx((hud.get_node("%HeatBar") as ProgressBar).value, 25.0), "HUD heat bar follows the stream")
	_check(is_equal_approx((hud.get_node("%RadiationBar") as ProgressBar).value, 50.0), "HUD radiation bar follows the stream")
	_check(is_equal_approx((hud.get_node("%O2Bar") as ProgressBar).value, 50.0), "HUD O2 bar shows remaining supply")
	_check((hud.get_node("%O2Row") as Control).visible, "HUD O2 row visible while the tool is equipped")
	EventBus.gauges_changed.emit({
		"heat": 0.0, "chill": 0.0, "radiation": 0.0, "o2": -1.0,
	})
	_check(not (hud.get_node("%O2Row") as Control).visible, "HUD hides the O2 row when the tool is not equipped")
	hud.free()


func _test_player_test_scene_loads() -> void:
	var packed: PackedScene = load("res://src/features/mechanics/scenes/player_test.tscn")
	_check(packed != null, "player_test.tscn loads")
	var scene := packed.instantiate()
	_check(scene.get_node_or_null("Cave") != null, "player_test.tscn contains the Cave zone")
	_check(scene.get_node_or_null("MissionHud") != null, "player_test.tscn contains the mission HUD")
	scene.free()
