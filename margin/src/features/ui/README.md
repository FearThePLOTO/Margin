# UI / Screens

Owner: (add name / @github-handle)

Station hub, loadout builder, debrief screen, and the Book of Books viewer.

## What goes here

- `scenes/` — one Control scene per screen (see `scenes/hub.tscn`), plus
  `scenes/mission_hud.tscn` — the in-mission gauges overlay (CanvasLayer)
- `scripts/` — screen logic (see `scripts/mission_hud.gd`)
- `themes/` — shared Theme resource so all screens match

## Never edit

- Other feature folders — talk via `EventBus`.
- `src/core/main.tscn` swaps your screens by `GameState.phase`; export clean,
  self-contained screen scenes.

## Signals you use (src/core/autoload/event_bus.gd)

- Emit: `tool_equipped`, `loadout_changed`, `budget_changed` (from loadout UI)
- Listen: `mission_failed`, `mission_completed`, `note_added`, `hazard_entered`,
  `gauges_changed` (mission HUD — heat/chill/radiation/o2 live values;
  `o2 = -1` means the O2 tool is not equipped, hide the bar)

## Conventions

- Screens are full-rect Control scenes; main.tscn instantiates them.
- All text values (budget, mass) read from `GameState` / autoloads — never
  duplicate them locally.
