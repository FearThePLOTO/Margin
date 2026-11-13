class_name GameConstants
## Shared numbers, traced to doc/research/. Update both places together.
## 2D note: physics gravity is in pixels/s^2, so convert m/s^2 by WORLD_PPM.

# -- world scale --
## Pixels per meter for the 320x180 pixel-art viewport.
const WORLD_PPM := 16.0

# -- environment (doc/research/, lunar) --
const MOON_GRAVITY_MSS := 1.62
const MOON_GRAVITY_PXS := MOON_GRAVITY_MSS * WORLD_PPM

# -- player system masses (movement_and_protection.md) --
const PLAYER_MASS_KG := 80.0    # assumed; pin as project constant
const SUIT_MASS_KG := 133.8     # tool.suit
const JETPACK_MASS_KG := 15.0   # tool.jetpack crafting mass

# -- game-tuned tool values (movement_and_protection.md, Jetpack Performance Metrics) --
const JETPACK_THRUST_GAME_N := 600.0  # sized to hover the 228.8 kg system with margin
const JETPACK_ISP_GAME_S := 300.0

# -- player movement (game-tuned, FLAGGED; traced to book.low_gravity) --
## book.low_gravity: a 3 m/s launch reaches ~2.78 m on the Moon (~6x Earth) —
## this is the jump that opens routes impossible on Earth.
const JUMP_SPEED_MSS := 3.0
## Game-tuned lunar lope (FLAGGED). Real xEMU data is metabolic effort, not a
## speed rating, so there is no sourced walk speed to copy.
const WALK_SPEED_MSS := 2.5
const GROUND_ACCEL_MSS := 8.0
const AIR_ACCEL_MSS := 4.0
const TERMINAL_FALL_PXS := 320.0
## Kid-friendly input grace. book.low_gravity: "a small extra push can send
## them a long way" — buffering keeps that from feeling punishing.
const COYOTE_TIME_S := 0.12
const JUMP_BUFFER_S := 0.12

# -- tether (movement_and_protection.md: force_n 2602.23, range_m 25.9) --
const TETHER_FORCE_N := 2602.23
const TETHER_RANGE_M := 25.9
const TETHER_MAX_ROPE_PXS := TETHER_RANGE_M * WORLD_PPM
const TETHER_MIN_ROPE_PXS := 48.0
const TETHER_REEL_SPEED_PXS := 64.0  # game-tuned (FLAGGED)
const SWING_PUMP_ACCEL_MSS := 3.0    # game-tuned (FLAGGED)
const SWING_PUMP_ACCEL_PXS := SWING_PUMP_ACCEL_MSS * WORLD_PPM
## book.tether_tension: slack arrests spike dynamic tension (T = m(g+a)·SF).
## Forgiving rule: above this speed the hook skids off instead of snapping.
const TETHER_SLIP_SPEED_PXS := 280.0

# -- spikes (movement_and_protection.md: tool.spikes) --
const SPIKES_CLIMB_SPEED_MSS := 0.8
const SPIKES_SLIDE_SPEED_MSS := 0.4
## Weakness: "very low pull-out resistance in loose regolith" — pitons slip
## after this long inside a LooseRegolith zone.
const SPIKES_REGOLITH_SLIP_S := 1.5
const WALL_JUMP_X_PXS := 3.0 * WORLD_PPM

# -- jetpack propellant (book.mass.rocket_equation) --
## Drain: mdot = F / (Isp * g0). 10 kg at 600 N / Isp 300 s ≈ 49 s of burn.
## Game-tuned capacity (FLAGGED); jetpack crafting mass is 15 kg total.
const JETPACK_PROPELLANT_KG := 10.0

# -- hazards: forgiving accrual rates (game-tuned, FLAGGED) --
## Zone ids come from level-design hazard zones via EventBus.hazard_entered.
## Rates are %/s of the fail threshold; recovery is passive — book.thermal.control:
## "plan routes that dart between shadows to passively cool down".
const HAZARD_FAIL_THRESHOLD := 100.0
const HAZARD_RATES := {
	&"SolarStormZone": {"heat": 10.0},
	&"PermanentShadow": {"chill": 7.0},
	&"RadioactiveWastes": {"radiation": 8.0},
}
const HAZARD_RECOVERY := {"heat": 12.0, "chill": 10.0, "radiation": 4.0}
