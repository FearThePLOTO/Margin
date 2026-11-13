extends Node
## Session state shared across features. Read it anywhere via GameState.<x>.
## Only put cross-feature data here; per-feature data stays in its feature folder.

enum Phase { HUB, LOADOUT, MISSION, DEBRIEF }

var phase: int = Phase.HUB
var objective_id: StringName = &""
var budget_used_usd: float = 0.0
var loadout: Array[StringName] = []
