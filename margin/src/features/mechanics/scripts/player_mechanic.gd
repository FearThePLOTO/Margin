class_name PlayerMechanic
extends RefCounted
## Base for player mechanics: one per file, owned by the Player coordinator.
## Each mechanic holds a reference to its player and exposes process(delta)
## plus whatever entry points its transitions need.

var player: Player


func _init(p: Player) -> void:
	player = p
