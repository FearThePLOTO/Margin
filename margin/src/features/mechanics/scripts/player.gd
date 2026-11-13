extends CharacterBody2D
## Placeholder player. Mechanics member: replace with the real movement model.
## Research: doc/research/movement_and_protection.md (jetpack, tether, spikes).

# 2D gravity is pixels/s^2 — scale the lunar value by your pixels-per-meter.
const LUNA_GRAVITY_MSS := 1.62  # see src/core/constants.gd

func _physics_process(_delta: float) -> void:
	# TODO(mechanics): implement movement tools + protection states.
	pass
