# Game Mechanics

Owner: (add name / @github-handle)

Player movement, tool behavior, protection/hazard damage, crafting, and the
loadout budget. All values trace to `doc/research/` — keep the trace.

NOTE: `player_test.tscn` instances the ui feature's `mission_hud.tscn` for
test-bench purposes only; the mission flow (main.tscn) will own the HUD once
the phase screens are built.

## What goes here

- `scenes/` — player rig, tool scenes (jetpack, tether, spikes, …)
- `scripts/` — movement, protection, damage, crafting logic
- `resources/` — tool stats as `.tres` resources (ids like `tool.jetpack.thrust`)

## You may also edit

- `src/core/main.gd` / `main.tscn` (game flow owner)

## Never edit

- Other feature folders (ui, level_design, audio) — talk via `EventBus`.

## Signals you use (src/core/autoload/event_bus.gd)

- Emit: `tool_used`, `tool_equipped`, `loadout_changed`, `budget_changed`,
  `gauges_changed` (player streams live heat/chill/radiation/o2 to the mission
  HUD every 0.1 s; `o2 = -1` means the O2 tool is not equipped)
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
- O2 (`scripts/mechanic_o2.gd`, tool `resources/tool_o2.tres`): equipped
  loadout tool (`tool.o2`). The CAVE is its domain and the O2 bar is the ONLY
  thing that changes there: the supply drains over time (`O2_SUPPLY_S` full
  drain) and an empty tank inside the cave fails the mission directly — no
  separate hazard gauge. The supply NEVER refills on its own; scattered tank
  pickups are the only refill. Without the tool there is no supply, so
  entering a cave fails on the spot. Its `mass_kg` is display-only like
  tether/spikes — `total_mass_kg()` counts only the jetpack.
- O2 tank pickups (`scenes/o2_tank.tscn`, `scripts/o2_tank.gd`): scattered
  tank nodes the level places inside/around caves. Touching one refills a
  fixed `O2_TANK_PICKUP` (30%) of the supply, clamped at full, and consumes
  the tank. The ONLY way the supply goes back up. Mechanics-internal node —
  no EventBus signals.
- Gauges stream to the mission HUD over `gauges_changed` (see signals above).
- Test scene: `scenes/player_test.tscn` (run it directly from the editor).
- Input actions (project.godot): `move_left/right/up/down` (WASD/arrows),
  `jump` (Space), `jetpack_thrust` (Shift/X), `tether_fire` (F),
  `spikes_deploy` (E).
- NOTE: `hazard_zone.gd` was added under `level_design/scripts/` — it is the
  zone→EventBus contract that README describes, needed by the test scene.

## Movement feel + animation (Celeste-style pass)

- `mechanic_move.gd`: variable jump height (release to cut, `JUMP_CUT_MULT`),
  heavier falls (`FALL_GRAVITY_MULT`), apex hang while jump is held, snappy
  ground stop (`GROUND_DECEL_PXS`), ceiling corner correction. Base gravity /
  jump speed are unchanged (research-traced).
- Sprite: `src/assets/char/astronaut_24.png` (24×24 cells, faces right; made by
  `tools/chargen/gen_char.py`). Clips in `player.tscn` SpriteFrames: idle,
  walk, takeoff, rise, apex, fall, land, thrust, slide (slide has art but no
  mechanic yet). `mechanic_animation.gd` resolves them.
- `player.gd`: `fail_is_death` export (training levels), camera locks to rooms
  via `room_entered`. `mechanic_death.gd` listens to `checkpoint_reached`,
  emits `player_died` / `player_respawned`, restores checkpoint O2.
