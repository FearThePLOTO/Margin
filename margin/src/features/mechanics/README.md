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

## Implemented (core trio)

- `scripts/player.gd` — lunar movement (gravity 1.62 m/s² × 16 px/m), jump
  (3 m/s launch → ~2.78 m, `book.low_gravity`), coyote time + jump buffer.
- Jetpack: thrust 600 N over the 228.8 kg system (net ~1.0 m/s²), propellant
  drains via mdot = F/(Isp·g0) (`book.mass.rocket_equation`).
- Tether: auto-targets the nearest `tether_anchor` above the player within
  25.9 m, taut-rope pendulum swing, reel with up/down, pump with left/right.
  Above the slip speed the hook skids off instead of snapping
  (`book.tether_tension`).
- Spikes: wall cling + climb, wall jump resets fall velocity; pitons slip
  after 1.5 s inside a `LooseRegolith` zone (research weakness).
- Hazards: listens to `hazard_entered`/`hazard_exited`, accrues heat/chill/
  radiation gauges slowly (forgiving), recovers passively outside zones.
  Gauge full → note into the Book of Books + `mission_failed`.
- Test scene: `scenes/player_test.tscn` (run it directly from the editor).
- Input actions (project.godot): `move_left/right/up/down` (WASD/arrows),
  `jump` (Space), `jetpack_thrust` (Shift/X), `tether_fire` (F),
  `spikes_deploy` (E).
- NOTE: `hazard_zone.gd` was added under `level_design/scripts/` — it is the
  zone→EventBus contract that README describes, needed by the test scene.
