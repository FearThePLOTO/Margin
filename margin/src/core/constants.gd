class_name GameConstants
## Shared numbers, tuned directly in PIXELS — no meter/PPM layer.
## doc/research/ stays as the reference story; feel is tuned here.

# -- environment --
const MOON_GRAVITY_PXS := 225.28

# -- player system masses (relative weights only; ratios, no unit conversion) --
const PLAYER_MASS_KG := 80.0
const SUIT_MASS_KG := 133.8
const JETPACK_MASS_KG := 15.0
const JETPACK_PROPELLANT_KG := 10.0

# -- player movement (pixel-tuned) --
const JUMP_SPEED_PXS := 192.0
const WALK_SPEED_PXS := 160.0
const GROUND_ACCEL_PXS := 512.0
const AIR_ACCEL_PXS := 256.0
const TERMINAL_FALL_PXS := 320.0
## Kid-friendly input grace (coyote time + jump buffering).
const COYOTE_TIME_S := 0.12
const JUMP_BUFFER_S := 0.12

# -- tether --
const TETHER_MAX_ROPE_PXS := 1657.6
const TETHER_MIN_ROPE_PXS := 48.0
const TETHER_REEL_SPEED_PXS := 64.0
const SWING_PUMP_ACCEL_PXS := 192.0
## Forgiving rule: above this speed the hook skids off instead of snapping.
const TETHER_SLIP_SPEED_PXS := 280.0

# -- spikes --
const SPIKES_CLIMB_SPEED_PXS := 51.2
const SPIKES_SLIDE_SPEED_PXS := 25.6
## Pitons slip after this long inside a LooseRegolith zone.
const SPIKES_REGOLITH_SLIP_S := 1.5
const WALL_JUMP_X_PXS := 192.0

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
