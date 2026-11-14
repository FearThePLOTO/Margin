# Core: the playable game

`src/core/` is the game that ships. `src/features/` holds in-production building
blocks (props, mechanics, menus) that core assembles.

| Path | What it is |
|---|---|
| `main.tscn` / `main.gd` | **Main scene.** Main menu, then Level 1 (new game or CONTINUE from the last checkpoint), then the results screen, then back to the menu. Also handles RESTART LEVEL. |
| `ui/main_menu.tscn` | Title card from the proposal opening (MARGIN pops in letter by letter, the tagline types out, PRESS ENTER) over a dense animated dust storm, then START NEW GAME / CONTINUE / OPTIONS / EXIT. |
| `ui/storm_background.gd` | The animated Mars dust storm (layers from `tools/uigen/gen_storm.py`). |
| `ui/pause_menu.tscn` | ESC in game: the game turns blue (`ui/shaders/pause_blue.gdshader`). RESUME, RETRY CHECKPOINT, RESTART LEVEL, BOOK OF BOOKS, OPTIONS, MAIN MENU. |
| `ui/settings_panel.tscn` | OPTIONS: music, sound, fullscreen (saved by the `Settings` autoload), NASA data sources. |
| `ui/pixel_menu.gd` | Shared kid-readable menu list (arrows, mouse, disabled rows). |
| `game/level_01/` | Level 1 "The Cave": `level_01.tscn`, root script (loadout + `GameState.level_id`), story dialogue (`dialogue/*.tres`). |
| `game/level_exit.tscn` | Level end: the "OUT ->" sign plus a trigger in the exit opening. Saves deaths and scrolls to the Book of Books, then shows results. Also works when a level is run alone (F6). |
| `ui/mission_overlay.tscn` | In-game UI: bottom HUD, cutscene letterbox + dialogue, Power Plan, scroll notification (top right, **B** reads now), the pause screen. |
| `ui/book_screen.tscn` | Book of Books: a pixel-art book. Level spread ("LEVEL 1 : THE CAVE", times died, scrolls), then **ENTER** to read one scroll per spread. **LEFT/RIGHT** turns pages, **B/ESC** goes back. |
| `ui/results_screen.tscn` | End of level: deaths, scrolls, time, and a link to the book. |
| `autoload/` | EventBus, GameState (also the CONTINUE checkpoint save), BookOfBooks (chapters + saved progress), SpaceWeather (NASA DONKI), Settings. |

Level 1 scrolls: one obvious (Hop room), one secret (above the radiation
skylight: climb the ledge under the broken roof, jump up through it, and cross
crumbling platforms before the storm radiation fills), and one in the lava climb.

Art generators: `tools/uigen/gen_logo.py` (logo + app icon), `gen_storm.py`
(menu storm), `gen_book.py` (Book of Books), `tools/chargen/gen_portraits.py`
(dialogue portraits).
