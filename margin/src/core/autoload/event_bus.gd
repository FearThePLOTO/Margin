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
## Instant-death hazard touched (lava pits); the player plays the death
## effect and respawns at its checkpoint.
signal hazard_kill(zone_id: StringName)

# --- level_design <-> mechanics (Celeste-style rooms + respawn) ---
## Player walked into a room: camera locks to `rect` (level space).
signal room_entered(rect: Rect2)
## Respawn point moved (rooms emit this on entry with their Spawn marker).
signal checkpoint_reached(position: Vector2)
## Death effect started / player is back at the checkpoint. Props reset on
## respawn (O2 tanks reappear), NPCs laugh on death.
signal player_died
signal player_respawned

# --- story: cutscenes + Conversation Module ---
## Play a DialogueSequence through the level's DialogueLayer (ui feature).
signal dialogue_requested(sequence: Resource)
signal dialogue_finished
## A new line appeared: who is speaking and whether it plays a sound cue
## (NPCs use it to animate, e.g. OG laughs on his laugh lines).
signal dialogue_line_started(speaker: String, has_sfx: bool)
## Player input is locked between these (cutscenes, power plan screen).
signal cutscene_started
signal cutscene_ended

# --- Junior Astronaut trade-offs (power / oxygen / shielding) ---
## A Power Station asks the UI for a new power plan.
signal power_plan_requested(station_id: StringName)
## Plan confirmed: {"o2": int, "shield": int, "light": int}, cells sum to GameState.power_cells.
signal power_plan_changed(plan: Dictionary)
## A Book of Books scroll was picked up; `chapter` = BookOfBooks chapter dict.
signal scroll_collected(chapter: Dictionary)
## Pause menu "MAIN MENU": main.gd swaps back to the title / main menu.
signal return_to_menu_requested
## Pause menu "RESTART LEVEL": main.gd reloads the current level fresh.
signal restart_level_requested
## SpaceWeather finished its live/archived lookup (see space_weather.gd).
signal space_weather_ready(info: Dictionary)
## Short on-screen tip (e.g. "Too dark to scan!").
signal hint_requested(text: String)

# --- any -> ui (debrief / Book of Books) ---
signal mission_failed(note_id: StringName, reason: String)
signal mission_completed(stats: Dictionary)
