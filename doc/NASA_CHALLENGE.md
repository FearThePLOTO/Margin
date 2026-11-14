# Margin: Junior Astronaut Mission Trainer

NASA Space Apps Challenge 2026, Cairo. Challenge: *Build a Junior Astronaut Mission Trainer*.

Margin is a 2D platformer for kids aged 7–12. They play Max, a new astronaut on Mars. A real
solar radiation storm forces Max to shelter in a lava tube. To get through it, the player has to
split a small suit battery between **air**, **radiation shielding** and **light**. No split is
free. The game uses real NASA space-weather data and tells the player where that data came from.

## The core trade-off

The suit battery starts with **3 cells**. Each Power Station charges **one new cell**: the player picks which system gets it (max 3 per system), then re-plans every cell:

| System | More cells means | Fewer cells means |
|---|---|---|
| AIR (CO2 scrubber) | oxygen drains slower (×0.55 at 3 cells) | oxygen drains faster (×1.45 at 0 cells) |
| SHIELD | the radiation meter fills slower (×0.35) | it fills faster (×1.6) |
| LIGHT (headlamp) | a bigger light, so you see lava, spikes and secrets | the cave is near-black |

Every cell given to one system is taken from another, so the "safe" choice always costs something.
The values are in `src/core/constants.gd`. The sizes are tuned for play, but each effect points the
same way it does in real life. The game says this openly on its *NASA DATA* screen.

Each station shows a forecast of what comes next (lava and air drain, a radiation skylight, a dark
spike tunnel), so kids plan ahead the way mission planners do:

- **Tube Entry**: lava pits and crumbling bridges, air draining.
- **Deep Tube**: a long tunnel, then a skylight where storm radiation pours in. Shield matters.
- **Dark Tunnel**: pitch black with spikes on the ceiling. Light matters, and air is running low.

## Real NASA data

| Dataset | How the game uses it |
|---|---|
| **DONKI** (Space Weather Database), SEP endpoint via `api.nasa.gov` | At startup, `SpaceWeather` (`src/core/autoload/space_weather.gd`) asks for Solar Energetic Particle events from the last 30 days. If a GOES satellite measured one, that real storm sets the radiation strength: **strong** for >100 MeV (×1.7), **medium** for >10 MeV (×1.3). If the Sun is quiet or the device is offline, the game uses one of **16 real GOES-measured SEP events** (May 2024 – Nov 2025, fetched from the same API), picked at random each run, and says so on screen. Stored data is never presented as live. The event ID and date appear in the cutscene, on the HUD and in the mission report. |
| **Curiosity RAD** (MSL Radiation Assessment Detector) | About 0.67 mSv per day on the Martian surface (Hassler et al., *Science*, 2014). Used on a science card and in the mission report. |
| **NASA Human Research Program / OSDR** | Bone mineral density loss of about 1–1.5% per month in microgravity. OSDR is named as the archive for this research, and OSDR RadLab is cited for ISS dosimetry. |
| **NASA life support data (BVAD)** | About 0.8 kg of oxygen per astronaut per day. Used on a science card and in the "air" lesson. |
| **NASA Veggie and CSA food production** | Lettuce grown and eaten on the ISS; the CSA's resource on food production on the Moon. |
| **NASA Mars facts** | Mostly-CO2 air at under 1% of Earth's pressure, 38% gravity, and a 24 h 39 min sol. Used in dialogue and science cards. |
| **Lava tube research** | Lava tubes have been proposed as radiation shelters; in Earth analog caves, radiation was about 82% lower inside. This is why Max shelters in a cave. |

Every Book of Books chapter shows its source. The main menu's **NASA DATA** screen lists all datasets,
plus a **Fact vs Game** section. For example, real Martian lava tubes are cold and ancient, so the
hot lava is only a game challenge.

## Mission flow

1. Title, then main menu: START GAME / SETTINGS / NASA DATA / QUIT.
2. **Touchdown**: Max leaves the lander and Mission Control briefs him (air, communication delay). Walking tutorial.
3. **Hop / Big Jump**: jumping, with hold for higher and tap for a short hop.
4. **Cave Mouth** on a high mesa (a letterboxed cutscene; the camera frames both characters): OG, an old hermit wizard, appears in a puff of magic and mocks Max with his cackle. This is his only appearance in Level 1. Mission Control then announces the real DONKI storm and the surface becomes dangerous, so Max has to go into the cave.
5. **Lava tubes** (7 rooms): Power Stations, falling platforms over lava, a vertical lava climb, a risky O2 tank, a radiation skylight, and a dark spike tunnel where short hops matter.
6. **Airlock**, then the **Mission Report**: the storm used (with its DONKI ID), every power plan chosen, time, samples, air tanks, restarts by cause, and plain-language lessons generated from the player's actual choices.

## Designed for 7–12 year olds

- Three resources only, in plain words: AIR, SHIELD, LIGHT.
- Science terms (sol, radiation, mSv) are explained where they appear.
- Failure is gentle. A death respawns Max at the start of the current room with at least half a tank of air, so trying a different plan is cheap.
- Replayability: a different real storm on each run, and different power plans lead to different outcomes.
- OG is annoying on purpose. His cackle shakes the dialogue text, Celeste-style.

## Credits

Pixel art, sound effects (synthesized) and code were made for Margin. Character proportions follow Eris Esra's Character Template 4.1. Fonts: Silkscreen and Pixelify Sans (OFL). Space weather data: NASA DONKI / CCMC.

## The Book of Books

Each level hides scrolls (3 in Level 1: one obvious, one in a secret chamber behind a hard challenge,
one tucked into a room). Each scroll unlocks a chapter of real space science (The Red Planet, Solar Storms,
Living in Space), written for 7-12 year olds with NASA sources. The book also records every level's best
deaths and scrolls, and it is saved between sessions. Open it from the main menu or the ESC pause menu.
