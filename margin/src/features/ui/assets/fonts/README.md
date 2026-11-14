# UI Fonts

Two OFL-licensed pixel fonts are used, with distinct roles:

| Role | Font | Used by |
|---|---|---|
| Display / wordmark | Pixelify Sans (variable, weight 400) | `TitleLabel` (34 px), reused by the Title Screen, Main Menu, and Settings Screen |
| Body / small UI text | Silkscreen Regular (original import) | Theme default font and `SupportLabel` subtitle/prompt/status (8 px) |
| Menu and dialog text | Silkscreen Menu (same Silkscreen font, menu-only import) | `MenuOptionButton` and `DialogOptionButton` (12 px), `DialogMessage` (9 px, Quit Confirmation), all with 2x oversampling |
| Conversation dialogue text | Silkscreen Dialogue (same Silkscreen font, dialogue-only import) | `DialogueMessage` and `DialogueText` (9 px), with 4x oversampling for a slightly smoother render |

Both fonts come from the official Google Fonts repository and are distributed under the SIL Open Font License 1.1:

- Pixelify Sans: <https://github.com/google/fonts/tree/main/ofl/pixelifysans> (source file `PixelifySans[wght].ttf`, stored here as `PixelifySans-Variable.ttf`)
- Silkscreen: <https://github.com/google/fonts/tree/main/ofl/silkscreen>

License texts are in `licenses/`. - `Silkscreen-Menu.ttf` is a byte-for-byte copy of the same
OFL Silkscreen font; the same license covers it. It exists only so the menu and dialog can
use a different Godot import preset without changing the approved title/body text.
`Silkscreen-Dialogue.ttf` is a byte-for-byte copy too, used only for the Conversation
Dialogue import preset; the same OFL license covers it.

## Why these fonts

- Pixelify Sans keeps the handmade pixel personality for large, prominent text where its irregular shapes are easy to read.
- Silkscreen is drawn on a strict pixel grid and stays legible at 8–12 px, so it is used for menu labels, instructions and feedback where Pixelify Sans becomes noisy.
- The Main Menu labels and Quit Confirmation text keep their established sizes, but use a
  shared import with `oversampling = 2.0`. At the 320x180 viewport this fills the strokes
  and softens the edges just enough to be easier to read, while preserving Silkscreen's
  pixel silhouette and the approved composition. The original Silkscreen import remains
  untouched for the 8 px prompt/subtitle/status.
- The Conversation Dialogue uses the same smoothing approach one step further:
  `Silkscreen-Dialogue.ttf` is a byte-for-byte copy of the same OFL Silkscreen font with
  `oversampling = 4.0`, applied only to `DialogueMessage` (speaker name) and `DialogueText`
  (body text). It renders slightly smoother and less pixelated at 9 px while keeping the
  pixel identity, and it never affects the Main Menu, Title Screen, Settings, or Quit
  Confirmation, which keep `Silkscreen-Menu.ttf` (2x).

At the 320x180 viewport, body text is 8 px (32 physical pixels at the standard 4x window
scale). Main Menu and dialog option text is 12 px; the dialog message stays at 9 px so it
fits on one line and remains subordinate to the actions. Dialogue speaker names and body
text also use 9 px so a line can wrap to three rows inside the 62 px dialogue panel. Do
not shrink below 8 px.

Normal, hover, and focus text uses pure white (`#FFFFFF`) so it stays readable on the
expected predominantly red artist background. The Main Menu and Quit Confirmation share the
short white `SelectionUnderline` instead of a focus rectangle. The 40% white title rule is
decorative.

## Selection underline

- `scenes/components/selection_underline.tscn` is the shared implementation. The Main Menu,
  Settings Screen, and Quit Confirmation each own one instance, and only the focused
  option has an underline.
- The indicator is a short bar with a constant 3 px thickness, square ends, and a
  uniform 90% white fill. Its width is the central half of the former text-width-plus-padding
  measure, so there are no thin extensions or tapered ends. It is centered on the text,
  not on the button box.
- Selection changes tween the indicator's position and width over 0.12 seconds. The
  Main Menu indicator hides immediately when the quit dialog opens and returns to QUIT GAME
  when the dialog closes. The dialog indicator hides as soon as either choice is made.
- The indicator color, width basis, gap, and thickness live in `themes/ui_theme.tres`
  under `MenuOptionButton`; `DialogOptionButton` inherits that configuration. Hovering
  moves focus to the hovered option, so focus remains the single source of truth.
- The Settings Screen owns one instance. Its MUSIC and SOUND EFFECTS label buttons use
  `MenuOptionButton`, so the same underline sits under the selected label and never
  overlaps the slider beside it.

## Settings volume sliders

- `scenes/components/volume_slider.tscn` is a custom-drawn horizontal control: one
  one-pixel track and ten short vertical ticks. Level 0 (MUTE) leaves every tick
  inactive; level 1 illuminates the first tick; level 10 illuminates all ten and
  fills the track. Inactive ticks stay visible at lower opacity.
- `scenes/components/audio_setting_row.tscn` pairs one label button with one slider.
  The label owns focus and the shared underline; the slider is a separate hit area
  that maps a click to the nearest of the eleven legal states (0–10).
- Slider colors, tick height, track thickness, and the selected-slider alpha boost
  live in `themes/ui_theme.tres` under `VolumeSlider`. Selection changes only the
  underline and a subtle track/tick alpha emphasis; it never changes the level.
- The Settings Screen is retained in `ui_root.tscn`, so both levels persist while the
  player moves between Main Menu and Settings. The UI currently keeps these values
  locally and does not call `AudioServer`; the runtime project exposes only the Master
  bus. Real Music/SFX integration belongs to the audio feature and requires an active
  bus layout and audio players outside this UI directory.

## Dialogue system

- `scenes/components/dialogue_box.tscn` is the reusable presentation overlay. It is
  independent of `ui_root.tscn`, the Main Menu background, and every gameplay scene.
  Its layout is a 288x62 top-centred panel with a 48x48 portrait slot at 320x180.
- Content is separate from presentation:
  - `dialogue/dialogue_line.gd` (`DialogueLine`) holds `speaker_name`, `portrait`, and
    `text`.
  - `dialogue/dialogue_sequence.gd` (`DialogueSequence`) holds the ordered `lines` array.
- Public API:
  - `start_dialogue(sequence: DialogueSequence)` opens the box and starts the first
    line. Starting a new sequence while one is active closes the old sequence first.
  - `dialogue_started` fires after the first line is shown; `dialogue_finished` fires
    once after the final line is closed.
  - `is_dialogue_active()`, `get_current_line_index()`, and
    `is_current_line_complete()` support non-invasive testing and integration.
- Both `ui_accept` and a left click on the dialogue panel reveal a line while it is
  typing. The same interaction advances only after the line is fully shown. The final
  line stays open until one more valid interaction, so it never closes automatically.
- The name and text use the smoother Silkscreen Dialogue typography through the
  `DialogueMessage` and `DialogueText` theme variations (4x oversampling). The Quit
  Confirmation keeps the original `DialogMessage` variation with `Silkscreen-Menu.ttf`.
  The panel reuses the existing dark `PanelContainer` style, the divider stays
  subordinate, and the continue indicator is a custom-drawn white triangle with no
  font-glyph dependency.
- A line with no portrait texture shows a clearly marked `PORTRAIT` placeholder. The
  system accepts a single static `Texture2D` per line and does not generate, animate,
  or crop character artwork.
- Run `scenes/dialogue_preview.tscn` directly (F6 in the editor or
  `godot --path margin res://src/features/ui/scenes/dialogue_preview.tscn`) to test
  the sample conversation. The preview uses a temporary teal background, sample
  content, and Enter to replay after completion.
- Gameplay integration is intentionally out of scope. A future gameplay system must
  add the dialogue box to a gameplay overlay, call `start_dialogue`, and lock player
  movement itself if required. Branching, choices, conditions, localization, quest
  effects, and story progression are deferred.

## Notes

- Godot 4.7 detects Silkscreen as a pixel font and disables hinting and subpixel positioning on import.
- `Silkscreen-Dialogue.ttf` keeps the same import params as `Silkscreen-Menu.ttf` except
  `oversampling = 4.0`, which is the only smoothing difference for the Conversation Dialogue.
- The Title Screen keeps the existing prompt opacity pulse while idle. The first valid key press or
  mouse click locks input and rapidly flashes only the prompt's opacity for about 1 second. The
  prompt never moves or changes size; its layout and white RGB stay fixed. The Main Menu transition
  and design are unchanged.
- Use `scenes/components/menu_button.tscn` for every Main Menu option; it applies the `MenuOptionButton` typography and hit area automatically.
- Use `scenes/components/audio_setting_row.tscn` for each Settings volume row; it keeps the label, slider, focus, and persistence wiring together. The Settings Screen focuses MUSIC on entry and uses explicit `focus_next` / `focus_previous` links to cycle MUSIC, SOUND EFFECTS, and BACK.
- `MainMenu` auto-discovers buttons with the `MenuOptionButton` variation for the shared underline. New options should use that variation and the `menu_button.tscn` component. Dialog actions use `DialogOptionButton`, which inherits the same typography and underline settings without joining the Main Menu navigation group.
- `DialogOptionButton` uses one zero-margin transparent style for every action state. That keeps the existing 64x18 dialog hit boxes and the 224 px panel unchanged while the underline supplies all selection feedback.
- Keep new fonts inside this folder (or `licenses/`) so the UI feature stays self-contained.
- Do not modify project-wide font settings; typography is assigned through `../themes/ui_theme.tres`.
