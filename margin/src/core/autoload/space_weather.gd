extends Node
## Space weather from NASA DONKI (Space Weather Database Of Notifications,
## Knowledge, Information): https://kauai.ccmc.gsfc.nasa.gov/DONKI/
##
## On startup it asks the DONKI SEP (Solar Energetic Particle) API for the last
## 30 days. SEPs are the solar radiation storms that matter for astronauts.
##  - LIVE: a GOES-measured SEP happened in the last 30 days -> that real storm
##    drives the mission's radiation.
##  - Otherwise the mission uses one REAL archived storm from ARCHIVE (fetched
##    from the same API, Nov 2026), picked at random each run (replayability),
##    and the game says so plainly: static data is never shown as live.
## Severity -> radiation multiplier: GOES >100 MeV = strong, >10 MeV = moderate.

const API := "https://api.nasa.gov/DONKI/SEP?startDate=%s&endDate=%s&api_key=DEMO_KEY"
const MULTIPLIER := {"quiet": 1.0, "moderate": 1.3, "strong": 1.7}

## Real GOES-measured SEP events from DONKI (curated, unmodified IDs/times).
const ARCHIVE: Array[Dictionary] = [
	{"id": "2024-05-10T13:35:00-SEP-001", "time": "2024-05-10T13:35Z", "instrument": "GOES-P: SEISS >10 MeV", "severity": "moderate", "flares": 8, "cmes": 6, "link": "https://ccmc.gsfc.nasa.gov/DONKI/view/SEP/30677/-1"},
	{"id": "2024-05-11T02:10:00-SEP-001", "time": "2024-05-11T02:10Z", "instrument": "GOES-P: SEISS >100 MeV", "severity": "strong", "flares": 1, "cmes": 1, "link": "https://ccmc.gsfc.nasa.gov/DONKI/view/SEP/30714/-1"},
	{"id": "2024-05-13T14:00:00-SEP-001", "time": "2024-05-13T14:00Z", "instrument": "GOES-P: SEISS >10 MeV", "severity": "moderate", "flares": 4, "cmes": 1, "link": "https://ccmc.gsfc.nasa.gov/DONKI/view/SEP/30817/-1"},
	{"id": "2024-06-08T02:25:00-SEP-001", "time": "2024-06-08T02:25Z", "instrument": "GOES-P: SEISS >100 MeV", "severity": "strong", "flares": 2, "cmes": 1, "link": "https://ccmc.gsfc.nasa.gov/DONKI/view/SEP/31338/-1"},
	{"id": "2024-06-08T02:55:00-SEP-001", "time": "2024-06-08T02:55Z", "instrument": "GOES-P: SEISS >10 MeV", "severity": "moderate", "flares": 2, "cmes": 1, "link": "https://ccmc.gsfc.nasa.gov/DONKI/view/SEP/31343/-1"},
	{"id": "2024-09-09T08:50:00-SEP-001", "time": "2024-09-09T08:50Z", "instrument": "GOES-P: SEISS >10 MeV", "severity": "moderate", "flares": 0, "cmes": 1, "link": "https://ccmc.gsfc.nasa.gov/DONKI/view/SEP/33257/-1"},
	{"id": "2024-09-17T07:35:00-SEP-001", "time": "2024-09-17T07:35Z", "instrument": "GOES-P: SEISS >10 MeV", "severity": "moderate", "flares": 1, "cmes": 1, "link": "https://ccmc.gsfc.nasa.gov/DONKI/view/SEP/33467/-1"},
	{"id": "2024-10-09T03:50:00-SEP-001", "time": "2024-10-09T03:50Z", "instrument": "GOES-P: SEISS >100 MeV", "severity": "strong", "flares": 1, "cmes": 1, "link": "https://ccmc.gsfc.nasa.gov/DONKI/view/SEP/33868/-1"},
	{"id": "2024-10-09T05:05:00-SEP-001", "time": "2024-10-09T05:05Z", "instrument": "GOES-P: SEISS >10 MeV", "severity": "moderate", "flares": 1, "cmes": 1, "link": "https://ccmc.gsfc.nasa.gov/DONKI/view/SEP/33866/-1"},
	{"id": "2024-10-26T18:05:00-SEP-001", "time": "2024-10-26T18:05Z", "instrument": "GOES-P: SEISS >10 MeV", "severity": "moderate", "flares": 2, "cmes": 2, "link": "https://ccmc.gsfc.nasa.gov/DONKI/view/SEP/34222/-1"},
	{"id": "2024-11-21T18:45:00-SEP-001", "time": "2024-11-21T18:45Z", "instrument": "GOES-P: SEISS >100 MeV", "severity": "strong", "flares": 0, "cmes": 1, "link": "https://ccmc.gsfc.nasa.gov/DONKI/view/SEP/35199/-1"},
	{"id": "2024-11-21T19:25:00-SEP-001", "time": "2024-11-21T19:25Z", "instrument": "GOES-P: SEISS >10 MeV", "severity": "moderate", "flares": 0, "cmes": 1, "link": "https://ccmc.gsfc.nasa.gov/DONKI/view/SEP/35208/-1"},
	{"id": "2025-11-10T11:25:00-SEP-001", "time": "2025-11-10T11:25Z", "instrument": "GOES-P: SEISS >10 MeV", "severity": "moderate", "flares": 1, "cmes": 1, "link": "https://ccmc.gsfc.nasa.gov/DONKI/view/SEP/42572/-1"},
	{"id": "2025-11-11T09:45:00-SEP-001", "time": "2025-11-11T09:45Z", "instrument": "GOES-P: SEISS >10 MeV", "severity": "moderate", "flares": 1, "cmes": 1, "link": "https://ccmc.gsfc.nasa.gov/DONKI/view/SEP/42608/-1"},
	{"id": "2025-11-11T10:20:00-SEP-001", "time": "2025-11-11T10:20Z", "instrument": "GOES-P: SEISS >100 MeV", "severity": "strong", "flares": 1, "cmes": 1, "link": "https://ccmc.gsfc.nasa.gov/DONKI/view/SEP/42612/-1"},
	{"id": "2025-11-14T09:20:00-SEP-001", "time": "2025-11-14T09:20Z", "instrument": "GOES-P: SEISS >10 MeV", "severity": "moderate", "flares": 1, "cmes": 1, "link": "https://ccmc.gsfc.nasa.gov/DONKI/view/SEP/42704/-1"},
]

var info: Dictionary = {}
var radiation_multiplier := 1.0
var ready_done := false

var _http: HTTPRequest


func _ready() -> void:
	randomize()
	_use_archived("offline")  # safe default until the live call returns
	_http = HTTPRequest.new()
	_http.timeout = 8.0
	add_child(_http)
	_http.request_completed.connect(_on_live)
	var now := Time.get_unix_time_from_system()
	var end := Time.get_date_string_from_unix_time(int(now))
	var start := Time.get_date_string_from_unix_time(int(now) - 30 * 86400)
	if _http.request(API % [start, end]) != OK:
		_finish()


## Re-roll the archived storm for a fresh mission (keeps a live storm if any).
func new_mission() -> void:
	if info.get("source", "") != "live":
		_use_archived(info.get("reason", "offline"))
		_finish()


func _on_live(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		_use_archived("offline")
		_finish()
		return
	var data: Variant = JSON.parse_string(body.get_string_from_utf8())
	var best: Dictionary = {}
	if data is Array:
		for e: Variant in data:
			if not (e is Dictionary):
				continue
			var inst := ""
			for i: Variant in e.get("instruments", []):
				inst = str(i.get("displayName", ""))
				if inst.contains("GOES"):
					break
			if not inst.contains("GOES"):
				continue
			var ev := {
				"id": str(e.get("sepID", "")), "time": str(e.get("eventTime", "")),
				"instrument": inst, "severity": "strong" if inst.contains(">100") else "moderate",
				"link": str(e.get("link", "")),
			}
			if best.is_empty() or ev.time > best.time or (ev.time == best.time and ev.severity == "strong"):
				best = ev
	if best.is_empty():
		_use_archived("quiet")  # live sun is calm: train on a real past storm
	else:
		_apply_event(best, "live", "")
	_finish()


func _use_archived(reason: String) -> void:
	_apply_event(ARCHIVE.pick_random(), "archived", reason)


func _apply_event(ev: Dictionary, source: String, reason: String) -> void:
	info = ev.duplicate()
	info["source"] = source
	info["reason"] = reason
	info["date"] = _pretty_date(str(ev.get("time", "")))
	info["level"] = "STRONG" if ev.get("severity") == "strong" else "MEDIUM"
	radiation_multiplier = MULTIPLIER.get(ev.get("severity", "quiet"), 1.0)


func _finish() -> void:
	ready_done = true
	EventBus.space_weather_ready.emit(info)


## One short kid-friendly sentence about where the storm data comes from.
func source_line() -> String:
	if info.get("source", "") == "live":
		return "LIVE NASA data: this storm is real, from %s!" % info.date
	return "A real storm NASA recorded on %s." % info.date


static func _pretty_date(iso: String) -> String:
	if iso.length() < 10:
		return iso
	var months := ["January", "February", "March", "April", "May", "June", "July",
			"August", "September", "October", "November", "December"]
	var m := int(iso.substr(5, 2))
	return "%s %d, %s" % [months[clampi(m - 1, 0, 11)], int(iso.substr(8, 2)), iso.substr(0, 4)]
