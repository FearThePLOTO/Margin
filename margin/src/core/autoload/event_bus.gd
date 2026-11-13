extends Node
## Global signal bus. The ONLY way features talk to each other.
## Features must not reference each other's scenes or scripts directly.
## When you add or change a signal, document it in BOTH feature READMEs.

# --- mechanics <-> ui ---
signal tool_equipped(tool_id: StringName)
signal loadout_changed(loadout: Array)
signal budget_changed(used_usd: float)

# --- mechanics -> ui (live gauges for the mission HUD) ---
signal gauges_changed(gauges: Dictionary)

# --- mechanics <-> level_design ---
signal hazard_entered(zone_id: StringName)
signal hazard_exited(zone_id: StringName)
signal tool_used(tool_id: StringName)

# --- any -> ui (debrief / Book of Books) ---
signal mission_failed(note_id: StringName, reason: String)
signal mission_completed(stats: Dictionary)
