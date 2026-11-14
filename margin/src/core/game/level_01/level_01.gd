extends Node2D
## Level 1 — "Lava Tubes" (training). Everything in this level is built in the
## editor: painted TileMapLayers (BackWall / Lava / Terrain / Decor) plus
## drag-and-drop prop scenes from scenes/props/ (Room, LavaZone, SludgeZone,
## SpikeZone, RadiationZone, CaveZone, FallingPlatform, O2Tank, OG, ExitDoor).
##
## This script only sets the mission loadout before anything spawns:
## training = no movement abilities, just the O2 supply for the cave rooms.

@export var loadout: Array[StringName] = [&"tool.o2"]


@export var level_id := "level_01"
## Music playlist for this level: tracks named <music>_<n>.ogg in
## src/features/audio/music/ (played in random order by the Music autoload).
@export var music: StringName = &"lava_and_cave"


func _enter_tree() -> void:
	GameState.loadout = loadout.duplicate()
	GameState.level_id = level_id


func _ready() -> void:
	Music.play(music)
