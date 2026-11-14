class_name ToolStats
extends Resource
## Tool stats as data, tuned in pixel/game units — no meter layer.
## Fields a tool does not use stay at their defaults.

@export var tool_id: StringName = &""
@export var display_name: String = ""
@export var mass_kg: float = 0.0        # relative weight only (mass ratios)
@export var thrust_pxs: float = 0.0     # jetpack: total thrust, pixel-units
@export var burn_time_s: float = 0.0    # jetpack: seconds of full-thrust burn
@export var propellant: float = 1.0     # jetpack: initial fill (0..1)
@export var range_px: float = 0.0       # tether: max rope length
@export var speed_px: float = 0.0
@export var cost_usd: float = 0.0
@export var unlocks: String = ""
