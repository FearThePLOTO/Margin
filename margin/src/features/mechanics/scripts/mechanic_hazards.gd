class_name PlayerHazardsMechanic
extends PlayerMechanic
## Forgiving accrual: hazard zones fill gauges slowly, leaving a zone recovers
## them passively (book.thermal.control: dart between shadows to cool down).

var heat := 0.0
var chill := 0.0
var radiation := 0.0

var _active_zones: Dictionary = {}  # zone_id -> true (via EventBus.hazard_entered)


func _init(p: Player) -> void:
	super(p)
	EventBus.hazard_entered.connect(_on_hazard_entered)
	EventBus.hazard_exited.connect(_on_hazard_exited)


func is_in_zone(zone_id: StringName) -> bool:
	return _active_zones.has(zone_id)


func process(delta: float) -> void:
	var rates := {"heat": 0.0, "chill": 0.0, "radiation": 0.0}
	for zone_id: StringName in _active_zones:
		var zone_rates: Dictionary = GameConstants.HAZARD_RATES.get(zone_id, {})
		for key: String in zone_rates:
			rates[key] += zone_rates[key]

	# Radiation = real space weather (SpaceWeather, NASA DONKI) x suit shielding
	# (power plan). A strong storm with no shield cells fills the meter fastest.
	if rates.radiation > 0.0:
		var cells: int = clampi(int(GameState.power_plan.get("shield", 1)), 0, 3)
		rates.radiation *= SpaceWeather.radiation_multiplier * GameConstants.SHIELD_DOSE_BY_CELLS[cells]

	if rates.heat > 0.0:
		heat = minf(heat + rates.heat * delta, GameConstants.HAZARD_FAIL_THRESHOLD)
	else:
		heat = maxf(heat - GameConstants.HAZARD_RECOVERY.heat * delta, 0.0)
	if rates.chill > 0.0:
		chill = minf(chill + rates.chill * delta, GameConstants.HAZARD_FAIL_THRESHOLD)
	else:
		chill = maxf(chill - GameConstants.HAZARD_RECOVERY.chill * delta, 0.0)
	if rates.radiation > 0.0:
		radiation = minf(radiation + rates.radiation * delta, GameConstants.HAZARD_FAIL_THRESHOLD)
	else:
		radiation = maxf(radiation - GameConstants.HAZARD_RECOVERY.radiation * delta, 0.0)

	GameState.peak_radiation = maxf(GameState.peak_radiation, radiation)

	if heat >= GameConstants.HAZARD_FAIL_THRESHOLD:
		player.fail(&"book.thermal.control",
				"Suit thermal limit exceeded in the Solar Storm Zone. Shadows reset the suit — dart between them, or anchor the shelter.")
	elif chill >= GameConstants.HAZARD_FAIL_THRESHOLD:
		player.fail(&"book.thermal.control",
				"Deep-cold exposure in the Permanent Shadow Zone. Cross shadows in short sprints — long hauls bleed the suit dry.")
	elif radiation >= GameConstants.HAZARD_FAIL_THRESHOLD:
		player.fail(&"book.radiation.shielding",
				"Radiation dose maxed out in the Radioactive Wastes. Dose falls exponentially with areal density — sprint through, never slow-haul.")


func _on_hazard_entered(zone_id: StringName) -> void:
	_active_zones[zone_id] = true


func _on_hazard_exited(zone_id: StringName) -> void:
	_active_zones.erase(zone_id)
