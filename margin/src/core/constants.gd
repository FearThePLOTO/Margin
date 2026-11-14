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
## Celeste-style feel (game-tuned on top of the research numbers above):
## releasing jump while rising cuts the arc (short hops), falls are heavier
## than rises, and the apex floats briefly while jump is held.
const JUMP_CUT_MULT := 0.45          # vy multiplier when jump is released early
const FALL_GRAVITY_MULT := 1.6       # gravity multiplier while falling
const APEX_HANG_PXS := 32.0          # |vy| under this counts as the apex...
const APEX_GRAVITY_MULT := 0.5       # ...where gravity halves while jump is held
const GROUND_DECEL_PXS := 900.0      # stop faster than you start (snappy)
const CORNER_CORRECT_PX := 4         # head-bonk nudge around ceiling corners
## Training levels respawn with at least this much O2 so a room is never lost.
const RESPAWN_O2_FLOOR := 0.5

# -- Junior Astronaut trade-offs: power cells -> system effect ----------------
## Index = cells given to that system (0..3). Game-tuned multipliers; the
## direction of every effect mirrors real suit/outpost engineering:
## more power to the CO2 scrubber = O2 lasts longer; more power to the active
## shield = less dose; more power to the headlamp = you can see and do science.
const O2_DRAIN_BY_CELLS := [1.45, 1.0, 0.72, 0.55]       # x O2 drain rate
const SHIELD_DOSE_BY_CELLS := [1.6, 1.0, 0.6, 0.35]      # x radiation fill rate
const LIGHT_SCALE_BY_CELLS := [0.3, 0.9, 1.4, 1.9]       # headlamp size (0 = a tiny glow)
const LIGHT_ENERGY_BY_CELLS := [0.3, 1.0, 1.25, 1.45]    # headlamp brightness
## Science scanners need at least this many headlamp cells to read a sample.
const SCAN_MIN_LIGHT_CELLS := 1

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

# -- O2 supply (equipped tool; the ONLY thing that changes inside a cave) --
## Inside a cave the O2 supply drains over time — no separate hazard gauge.
## Empty tank inside the cave fails the mission directly. Outside caves it
## refills passively. book.life_support.o2.
const O2_SUPPLY_S := 45.0          # seconds of full supply inside a cave
const O2_TANK_PICKUP := 0.3        # fixed refill of every scattered O2 tank
