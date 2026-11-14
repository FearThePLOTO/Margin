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
  name matches its `zone_id` (e.g. `RadioactiveWastes`, `PermanentShadow`,
  `Cave`). Zone ids map to gauges in `GameConstants.HAZARD_RATES`:
  `SolarStormZone` (heat), `PermanentShadow` (chill), `RadioactiveWastes`
  (radiation). `Cave` is special — it has NO hazard gauge; the player's O2
  supply drains inside it and an empty tank fails the mission (mechanics'
  `mechanic_o2.gd`). Scatter `o2_tank.tscn` pickups (mechanics feature, same
  pattern as `tether_anchor.tscn`) inside caves so crossings are feasible —
  each tank refills a fixed 30% of the supply.

## Level 1 — "Shelter" (story + Junior Astronaut trade-offs)

`scenes/level_01.tscn` is built entirely in the editor. The root script only sets the
loadout. The level has two parts:

- **Surface** (`S1_Touchdown` → `S4_CaveMouth`): parallax sky (`Sky_*` Parallax2D layers from `src/assets/sky/`: stars, Phobos + Deimos, far/mid/near ridges), blowing dust, lander touchdown intro, walk and jump tutorial,
  a high mesa with a small cave mouth. `Cutscene_S4` reveals OG, plays `l1_og_mock`,
  then switches on `Hazards/SurfaceStorm` and `StormTint`. `Story/CaveMouth` (warp)
  only works after that cutscene and drops Max at `R1_TubeEntry/Spawn`.
- **Lava tubes** (`R1`–`R7`): the whole area is a `Cave` zone (O2 drains, `CaveLighting`
  darkens the screen). Power Stations sit in R1, R4 and R6. The radiation skylight is R5,
  the dark spike tunnel is R6, and the exit airlock is R7.

Story text lives in `resources/dialogue/*.tres` (DialogueSequence). Lines may use
`{storm_level}`, `{storm_date}` and `{storm_source}`; these are filled from real NASA
DONKI data at runtime.

### Drag-and-drop props (`scenes/props/`)

| Scene | Inspector fields |
|---|---|
| `room.tscn` | resize `Shape` (Make Unique first), move `Spawn` |
| `cutscene_trigger.tscn` | `sequence`, `autostart`, `reveal_nodes`, `hide_after`, `activate_after`, `camera_focus` (Marker2D the camera glides to) |
| `power_station.tscn` | `station_name`, `forecast` (opens the 3-cell Power Plan) |
| `scroll.tscn` | `chapter_id` (a chapter in `book_of_books.gd`), `first_scroll`: unlocks a Book of Books chapter |
| `hint_sign.tscn` | `text` |
| `warp.tscn` | `target` (Marker2D), `requires` (a cutscene trigger) |
| `lander.tscn` | `land_on_start` (touchdown intro with flame + dust burst) |
| `dust_wind.tscn` | screen-space wind + dust, hidden in caves; `intensify()` on storm |
| `og_npc.tscn`, `exit_door.tscn`, `falling_platform_64.tscn` | |
| `lava_zone` / `sludge_zone` / `spike_zone` (kill), `radiation_zone`, `cave_zone` | resize `Shape` |

Dialogue appears at the TOP of the screen (Celeste-style). Character lines show a 64x64 illustrated portrait (`src/assets/char/portraits_64.png`, 64 px per frame: 0-4 Max normal/happy/scared/annoyed/surprised, 5-8 OG smug/laugh/talk/grin); tick **Portrait On Right** for non-player characters. Any speaker named `NASA ...` is shown as a green uplink terminal instead of a portrait. Dialogue lines support Celeste-style text effects: `[shake rate=22 level=7]HAHA[/shake]` for angry or laughing lines, `[wave amp=28 freq=5]magic[/wave]` for weird ones, and tick **Shake Box** on a line for a box jolt.

The level also needs a `CanvasModulate` with `cave_lighting.gd`, plus `mission_overlay.tscn`
(ui feature: compact HUD, letterbox cutscenes, dialogue, Power Plan, fact cards).
The Player instance needs **Fail Is Death** turned on.

### Scrolls + secret chamber (Level 1)

Three scrolls, one per Book of Books chapter:
- `Scroll_S2` (obvious, tutorial: its card explains the book),
- `Scroll_R1b` in `R1b_SecretChamber`: drop through the `FakeFloor` tile in the
  corner behind the R1 spawn (it looks like rock and carries a faint crack decal),
  then cross a falling platform under a spike ceiling while air drains;
  `Story/SecretWayOut` warps back to `Story/SecretExit` in R1,
- `Scroll_R3` (obvious, in the lava climb).

The exit door reports `scrolls_total`; main.gd saves deaths + scrolls with
`BookOfBooks.record_level()` and shows the results screen.
