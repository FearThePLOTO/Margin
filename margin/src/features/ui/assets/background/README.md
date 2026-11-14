# Shared UI Background

The Main Menu flow uses one persistent background owned by `scenes/ui_root.tscn`:

```
UIRoot
├── Background              (shared, never reloaded on screen changes)
│   └── Video               (VideoStreamPlayer, artist-provided OGV)
└── ScreenHost
    ├── TitleScreen         (transparent foreground)
    ├── MainMenu            (transparent foreground)
    └── SettingsScreen      (transparent foreground)
```

The background video is `main_menu_background.ogv`, which is a 16:9 Theora file. The
shared `Background` stays in the UI root while the screens above it are swapped, so
navigation between Title, Main Menu, Settings, and the Quit Confirmation dialog never
reloads or restarts the video.

## Video integration

- `Background/Video` uses `VideoStreamPlayer`.
- The stream is `main_menu_background.ogv` in this folder.
- `autoplay` is enabled so playback starts when the UI root loads.
- `loop` is enabled so the video repeats continuously.
- `expand` is enabled so the video fills the shared background area.
- The background and video ignore mouse input so screens and dialogs stay interactive.
- There is no user-facing playback control or video setting.

Do not add background images to individual screen scenes. Screens must stay
transparent so the shared layer remains visible and does not flash.

The Conversation Dialogue System is separate and must not be added to this layer.
