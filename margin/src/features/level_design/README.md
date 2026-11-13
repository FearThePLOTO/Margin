# Level Design

Owner: (add name / @github-handle)

Mission levels as 2D scenes, with hazard-zone areas (radiation, thermal, storm,
lava) matching the research environment data.

## What goes here

- `scenes/` — one `.tscn` per mission level (`level_01.tscn` = "The Cave")
- `scenes/blocks/boundary_block_16.tscn` — 16×16 greybox block, scaled per wall
- `scenes/props/` — reusable level props (falling platform)
- `scripts/` — level props and framing only: `hazard_zone.gd`,
  `falling_platform.gd`, `level_switch.gd`, `level_01.gd`
- `tilesets/` — reserve for the final art pass; the greybox level uses
  `ColorRect` visuals so nothing depends on imported textures yet
- `resources/` — zone data resources (zone id, damage/temp rate, bounds)

## Never edit

- Other feature folders — talk via `EventBus`.

## Signals you use (src/core/autoload/event_bus.gd)

- Emit: `hazard_entered`, `hazard_exited` (from Area2D zone nodes)
- Listen: `tool_used` (e.g. shelter deployed, zone counters)

## Conventions

- Name levels `level_<number>.tscn`; place the player start at origin.
- Zone nodes: group under a `HazardZones` Node2D, each zone an Area2D whose
  name matches its `zone_id` (e.g. `RadioactiveWastes`, `PermanentShadow`).
  When several pools are one hazard, set `zone_id` and give each node a unique
  name — every lava pool here uses `zone_id = &"LavaZone"`.
- Floor tops sit on a 16 px grid; the player's feet rest 14 px above a floor.
  All solids are multiples of 16 px so they can be swapped for tiles later.
- Static rooms are one 320×180 screen. `level_01.gd` (`rooms` array) locks the
  camera to a room rect while the player is inside it, and back to
  `world_bounds` outside.

## level_01 — "The Cave"

Run it with **F6** (the level instantiates `player.tscn` itself). `main.tscn`
is untouched. Sketch: `…/Margin/temp/Cave.md`.

Flow, left to right:

1. **Surface** (`x 288..704`, floor top `y = 0`) — the player drops in at
   `x = 560`, walks left and falls into the cave shaft (`x 160..288`, 288 px
   down).
2. **Room 1** (`x 160..1056`, scrolling, floor top `y = 288`) — tutorial: two
   64 px lava pits and a 32 px step.
3. **Room 2** (`x 1056..1376`, static screen) — three ledges over a lava pit.
   `ItemSpawn_Room2Exit` marks the O2 tank spot by the exit door.
4. **Room 3** (`x 1376..1696`, static screen) — two falling platforms over a
   lava pit, a switch on the far floor, and a high wall. The switch extends
   `Solids/HighWallPlatform`, the step needed to reach the door slot at the top
   of the wall (`y 160..192`).
5. **End** (`x 1696..1792`, floor top `y = 192`) — `EndZone` in the doorway.

Every room is entered from the left and left through the right, matching the
sketch: door gaps are 48 px tall at floor level, except room 3's high door.

### Nodes

- `Solids/*` — scaled `boundary_block_16` instances: surface, cave walls,
  ceilings, room floors, lava basins, ledges, `HighWall`, doorway walls.
- `Solids/HighWallPlatform` — the step in room 3's high wall. Ships
  `visible = false` with its `CollisionShape2D.disabled = true`.
- `Switches/Switch_HighWall` (`1628, 268`) — one-shot Area2D; `target_path`
  points at `../../Solids/HighWallPlatform`. Touching it enables the step.
- `Platforms/FallingPlatform_R3_1..2` — shake 0.6 s, fall, hide, respawn 2.5 s
  after dropping. Tuning is exported on the script.
- `TetherAnchors/TetherAnchor_R2_A..B`, `_R3_A..B` — existing mechanic anchors,
  176 px down from the ceiling.
- `Items/ItemSpawn_Room2Exit` — bare `Marker2D` for the O2 tank. Nothing
  spawns from it yet.
- `EndZone` — Area2D in group `level_exit`, in the end doorway. Nothing
  listens yet.

### Wiring left for the mechanics/gameplay owners

- `LavaZone` is not in `GameConstants.HAZARD_RATES` (`src/core/constants.gd`).
  Add `&"LavaZone": {"heat": …}` (or a new gauge) or the pools do nothing.
  All four pools emit the same `&"LavaZone"` id; separate nodes only let each
  pool sit at its own position.
- Falling into a lava pool emits `hazard_entered` and the player can jump out.
  Wire mission fail/respawn (or a high enough lava rate) in the mechanics
  feature.
- `EndZone` needs a listener to advance the level; `ItemSpawn_Room2Exit` needs
  the O2 tank spawn logic.
