# Margin

**In deep space, survival isn't magic. It's knowing your margins.**

Margin is a 2D pixel-art platformer for children aged 7 to 12, made by team **Ape-ollo 11** for the NASA Space Apps Challenge 2026 (Cairo), challenge **"Build a Junior Astronaut Mission Trainer"**.

You play Max, a young astronaut who has just landed on Mars. A real solar radiation storm, taken from NASA data, forces him into a lava tube cave with no breathable air. To survive, you split a small suit battery between **Air**, **Shield** and **Light**. Every cell you give one system is a cell another system loses.

| | |
|---|---|
| Play it | https://feartheploto.itch.io/margin (Windows, Linux, web browser) |
| NASA Project page | https://www.spaceappschallenge.org/2026/find-a-team/cosmoholics/?tab=project |
| Demo | https://drive.google.com/drive/folders/1ySRO2H9PQ2--0YvnNxVgVHD1UlV0VeTg |
| Project description (PDF) | [doc/Margin_Project_Description.pdf](doc/Margin_Project_Description.pdf) |

## How the game works

- **Power plan.** The suit starts with 3 battery cells. Each Power Station adds one new cell. You choose which system gets it (up to 3 per system), then move your cells around.
  - **Air:** more cells make oxygen last longer in the cave.
  - **Shield:** more cells make radiation build up more slowly.
  - **Light:** more cells give a bigger headlamp, so you can see lava, spikes and secret paths.
- **Real space weather.** At startup the game asks NASA's DONKI database for solar particle storms from the last 30 days. A real storm makes radiation stronger. If the Sun was quiet or you are offline, the game uses one of 16 real storms measured by GOES satellites, and it always tells you which.
- **Book of Books.** Level 1 hides 3 scrolls. Each one unlocks a short science chapter with its NASA source. The book also keeps your deaths and scrolls per level.
- **Gentle failure.** Dying sends Max back to the start of the room with air left, so trying a new plan is cheap.

## Controls

| Action | Keys |
|---|---|
| Move | A / D or Left / Right |
| Jump (hold to jump higher) | Space |
| Change power plan at a station | W or Up |
| Open the Book of Books | B |
| Pause | Esc |
| Menus | Arrow keys and Enter (mouse works too) |

## Running from source

1. Install **Godot 4.7.2** (standard build): https://godotengine.org/download
2. Open `margin/project.godot` in Godot.
3. Press **F5**. The main scene is `res://src/core/main.tscn`.

To play a single level on its own, open it (for example `src/core/game/level_01/level_01.tscn`) and press **F6**.

## Exporting builds

Export presets for **Linux**, **Windows Desktop** and **Web** are in `margin/export_presets.cfg`, and each one writes to its own folder in `margin/exports/`. With the Godot 4.7.2 export templates installed, run from `margin/`:

```bash
godot --headless --export-release "Linux" exports/linux/Margin.x86_64
godot --headless --export-release "Windows Desktop" exports/windows/Margin.exe
godot --headless --export-release "Web" exports/web/index.html
```

The web build is single-threaded, so it needs no special server headers. Serve it over HTTP (for example `python3 -m http.server` inside `exports/web`) instead of opening the file directly.

## Repository layout

```
Margin/
├── README.md                 this file
├── LICENSE                   MIT licence
├── .pre-commit-config.yaml   git hook that blocks commits on main
├── doc/                      challenge write-up, research notes, project PDF
└── margin/                   the Godot project
    ├── project.godot
    ├── export_presets.cfg    Linux, Windows and Web export presets
    ├── exports/              exported builds (ignored by Godot)
    ├── src/
    │   ├── core/             the game that ships: main scene, Level 1, in-game UI, autoloads
    │   ├── features/         reusable building blocks: mechanics, level props, UI parts, audio
    │   └── assets/           generated pixel art: tiles, characters, sky, UI art
    ├── tools/                Python generators for the art and sound effects
    └── tests/                headless smoke tests
```

**Core vs features:** everything in `src/core/` is the current game. `src/features/` holds parts that are still "in production" and are assembled by core. Features talk to each other only through the `EventBus` autoload.

## README index

Each folder that needs explaining has its own README.

| README | What it covers |
|---|---|
| [margin/src/core/README.md](margin/src/core/README.md) | The playable game: main scene and game flow, Level 1, the level exit, the main menu with the storm title, the pause screen, options, the Book of Books screen, the results screen and the autoloads (EventBus, GameState, BookOfBooks, SpaceWeather, Settings, Music). Start here to understand the game. |
| [margin/src/features/mechanics/README.md](margin/src/features/mechanics/README.md) | The player: movement, animation, death and respawn, oxygen, hazards and tools, plus the rules for working inside this feature. |
| [margin/src/features/level_design/README.md](margin/src/features/level_design/README.md) | How levels are built from drag-and-drop props: rooms and the room camera, hazard zones (lava, radiation, cave), falling platforms, cutscene triggers, power stations, scrolls, signs and dialogue resources. |
| [margin/src/features/ui/README.md](margin/src/features/ui/README.md) | The reusable UI parts: the dialogue box (portraits, NASA terminal, shaking text), the shared theme and older menu screens. |
| [margin/src/features/ui/assets/fonts/README.md](margin/src/features/ui/assets/fonts/README.md) | The two pixel fonts (Silkscreen and Pixelify Sans), why each is used, their import settings and their OFL licences. |
| [margin/src/features/ui/assets/background/README.md](margin/src/features/ui/assets/background/README.md) | The video background used by the earlier menu screens. |
| [margin/src/features/audio/README.md](margin/src/features/audio/README.md) | Music and sound effects: the audio buses, file naming, and how music playlists (`<playlist>_<n>.ogg`) are played in random order. |
| [margin/src/assets/Margin_Mars_Surface/Documentation/README.md](margin/src/assets/Margin_Mars_Surface/Documentation/README.md) | The 16 by 16 Mars tileset: how it is generated, the guarantees it is checked against, and how to paint with it in Godot. |
| [margin/tests/README.md](margin/tests/README.md) | How to run the headless smoke tests and what they cover. |

Other documents:

| Document | What it is |
|---|---|
| [doc/NASA_CHALLENGE.md](doc/NASA_CHALLENGE.md) | How Margin answers the challenge: the power trade-off, every NASA dataset used, and the design for 7 to 12 year olds. |
| [doc/research/](doc/research/) | Research notes behind the game: Mars facts, movement and protection, movement tools. |
| [doc/Margin_Project_Description.pdf](doc/Margin_Project_Description.pdf) | The submission document: summary, details, NASA data, references and AI disclosure. |

## Asset generators

The pixel art and sound effects are made by Python scripts, so edit the script and run it again instead of editing the PNG or WAV files. They need Python 3 with Pillow and NumPy, and are run from `margin/`.

| Script | Makes |
|---|---|
| `tools/tilegen/` | The Mars tileset and its Godot TileSet |
| `tools/chargen/gen_char.py` | Max, OG, the lander, icons, signs and the scroll |
| `tools/chargen/gen_portraits.py` | The 64 by 64 dialogue portraits |
| `tools/skygen/gen_sky.py` | The parallax sky with Phobos and Deimos |
| `tools/uigen/gen_logo.py` | The MARGIN logo and the app icon |
| `tools/uigen/gen_storm.py` | The main menu dust storm layers |
| `tools/uigen/gen_book.py` | The Book of Books art |
| `tools/sfxgen/gen_sfx.py` | The sound effects (voices, OG's laugh, station sounds) |

## Contributing

Run this once after cloning:

```bash
pip install --user pre-commit   # or: pipx install pre-commit
pre-commit install
```

This installs the git hook from `.pre-commit-config.yaml`, which refuses commits made directly on `main`. Create a branch, then open a pull request. To run the checks by hand: `pre-commit run --all-files`.

## NASA data

- **DONKI** (Space Weather Database), via https://api.nasa.gov: live and stored solar particle storms set the radiation strength.
- **Curiosity RAD**: about 0.67 mSv of radiation per day on Mars.
- **NASA BVAD**: about 0.8 kg of oxygen per astronaut per day.
- **NASA Human Research Program, OSDR and RadLab**, **NASA Mars facts** and **NASA Veggie**: used in the Book of Books chapters.

Full details, links and how each source is used are in [doc/NASA_CHALLENGE.md](doc/NASA_CHALLENGE.md) and the project PDF.

## Credits

- Engine: Godot 4.7 (MIT).
- Fonts: Silkscreen and Pixelify Sans (SIL Open Font License 1.1).
- Music: original, produced by a team member.
- Character proportions follow Eris Esra's Character Template 4.1.
- Pixel art and sound effects: generated by our own scripts.
- AI assistance: Claude Code (Anthropic) helped write code, the asset scripts and text. See the AI section of the project PDF.

## License

MIT. See [LICENSE](LICENSE).
