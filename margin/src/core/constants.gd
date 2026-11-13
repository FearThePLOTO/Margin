class_name GameConstants
## Shared numbers, traced to doc/research/. Update both places together.
## 2D note: physics gravity is in pixels/s^2, so convert m/s^2 by your world scale.

# -- environment (doc/research/, lunar) --
const MOON_GRAVITY_MSS := 1.62

# -- player system masses (movement_and_protection.md) --
const PLAYER_MASS_KG := 80.0    # assumed; pin as project constant
const SUIT_MASS_KG := 133.8     # tool.suit
const JETPACK_MASS_KG := 15.0   # tool.jetpack crafting mass

# -- game-tuned tool values (movement_and_protection.md, Jetpack Performance Metrics) --
const JETPACK_THRUST_GAME_N := 600.0  # sized to hover the 228.8 kg system with margin
const JETPACK_ISP_GAME_S := 300.0
