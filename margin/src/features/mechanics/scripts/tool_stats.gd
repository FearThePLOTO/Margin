class_name ToolStats
extends Resource
## Tool stats as data. Game values trace to doc/research/movement_and_protection.md
## and doc/research/movement-tools.md — keep the trace, update research + .tres together.
## Fields a tool does not use stay at their defaults.

@export var tool_id: StringName = &""
@export var display_name: String = ""
@export var mass_kg: float = 0.0
@export var force_n: float = 0.0
@export var range_m: float = 0.0
@export var speed_ms: float = 0.0
@export var isp_s: float = 0.0
@export var propellant_kg: float = 0.0
@export var cost_usd: float = 0.0
@export var unlocks: String = ""
