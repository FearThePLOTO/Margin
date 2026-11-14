# Audio

Owner: (add name / @github-handle)

Music, SFX, and the audio bus layout (Music / SFX / Master).

## What goes here

- `music/` — music playlists: name tracks `<playlist>_<n>.ogg` (`ui_music_1.ogg`, `lava_and_cave_3.ogg`). The `Music` autoload (`src/core/autoload/music.gd`) plays a playlist in random order, never repeating a track back to back, and crossfades between playlists. `ui_music` = menus and results, `lava_and_cave` = Level 1 (set per level with the level root's `music` export). A new numbered file joins its playlist automatically.
- `sfx/` — one-off sounds (tool use, hazard warnings, UI clicks)
- `default_bus_layout.tres` — bus layout, already wired into project settings

## Never edit

- Other feature folders — talk via `EventBus`.

## Signals you use (src/core/autoload/event_bus.gd)

- Listen: `tool_used`, `hazard_entered`, `mission_failed`, `mission_completed`

## Conventions

- Route Music players to the `Music` bus and SFX players to the `SFX` bus.
- Name files by what they sound like + where used, e.g. `sfx_jetpack_burst.ogg`.
