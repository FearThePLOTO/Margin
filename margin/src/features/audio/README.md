# Audio

Owner: (add name / @github-handle)

Music, SFX, and the audio bus layout (Music / SFX / Master).

## What goes here

- `music/` — music tracks (hub, mission, debrief)
- `sfx/` — one-off sounds (tool use, hazard warnings, UI clicks)
- `default_bus_layout.tres` — bus layout, already wired into project settings

## Never edit

- Other feature folders — talk via `EventBus`.

## Signals you use (src/core/autoload/event_bus.gd)

- Listen: `tool_used`, `hazard_entered`, `mission_failed`, `mission_completed`

## Conventions

- Route Music players to the `Music` bus and SFX players to the `SFX` bus.
- Name files by what they sound like + where used, e.g. `sfx_jetpack_burst.ogg`.
