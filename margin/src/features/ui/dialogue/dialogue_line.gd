extends Resource
class_name DialogueLine
## One presented line of dialogue. Content authors can build these as .tres
## resources or construct them in code; the dialogue box only reads them.

@export var speaker_name: String = ""
## Illustrated portrait (64x64, src/assets/char/portraits_64.png). Lines from a
## speaker named "NASA ..." ignore it and use the uplink terminal instead.
@export var portrait: Texture2D
## Celeste-style sides: the player on the left, other characters on the right.
@export var portrait_on_right := false
@export_multiline var text: String = ""
## Optional typing voice: a short blip played every few revealed characters
## (pitch is jittered so it "talks"), e.g. res://src/features/audio/sfx/og_voice.wav.
@export var voice: AudioStream
@export_range(0.5, 2.0, 0.05) var voice_pitch := 1.0
## Optional one-shot sound when the line appears (e.g. og_laugh.wav).
@export var sfx: AudioStream
## Celeste-style jolt: the whole box shakes when the line appears (shouting,
## alarms, angry laughs). For per-letter wobble use BBCode in `text`:
## [shake rate=20 level=6]HAHA[/shake] (angry / laughing) or
## [wave amp=30 freq=5]weird[/wave] (strange / magical).
@export var shake_box := false
