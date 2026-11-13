# Game Mechanics

Owner: (add name / @github-handle)

Player movement, tool behavior, protection/hazard damage, crafting, and the
loadout budget. All values trace to `doc/research/` — keep the trace.

## What goes here

- `scenes/` — player rig, tool scenes (jetpack, tether, spikes, …)
- `scripts/` — movement, protection, damage, crafting logic
- `resources/` — tool stats as `.tres` resources (ids like `tool.jetpack.thrust`)

## You may also edit

- `src/core/main.gd` / `main.tscn` (game flow owner)

## Never edit

- Other feature folders (ui, level_design, audio) — talk via `EventBus`.

## Signals you use (src/core/autoload/event_bus.gd)

- Emit: `tool_used`, `tool_equipped`, `loadout_changed`, `budget_changed`
- Listen: `hazard_entered`, `hazard_exited`

## Notes

- 2D gravity is in pixels/s^2. Lunar 1.62 m/s^2 (see `src/core/constants.gd`)
  must be scaled by your world pixels-per-meter before use.
- Extra movement tools (drone/bridge/ascender/winch) are FLAGGED pending the
  propulsion decision — don't implement until the team decides.
