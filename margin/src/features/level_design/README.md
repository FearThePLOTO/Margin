# Level Design

Owner: (add name / @github-handle)

Mission levels as 2D TileMap scenes, terrain tilesets, and hazard-zone areas
(radiation, thermal, storm) matching the research environment data.

## What goes here

- `scenes/` — one `.tscn` per mission level (see `scenes/level_01.tscn`)
- `tilesets/` — moon terrain tileset, hazard-zone tiles
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
