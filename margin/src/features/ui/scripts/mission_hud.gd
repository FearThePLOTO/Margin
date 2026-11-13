extends CanvasLayer
## Mission HUD: live hazard + O2 gauges. Listens to EventBus.gauges_changed —
## the mechanics feature owns the values; never reference player scenes here
## (feature boundary, see this feature's README).
## Hazard bars fill toward the fail threshold; the O2 bar empties as the
## supply drains and hides entirely when the O2 tool is not equipped (o2 < 0).

@onready var _heat: ProgressBar = %HeatBar
@onready var _chill: ProgressBar = %ChillBar
@onready var _radiation: ProgressBar = %RadiationBar
@onready var _o2: ProgressBar = %O2Bar
@onready var _o2_row: Control = %O2Row


func _ready() -> void:
	EventBus.gauges_changed.connect(_on_gauges_changed)


func _on_gauges_changed(gauges: Dictionary) -> void:
	_heat.value = gauges.get("heat", 0.0)
	_chill.value = gauges.get("chill", 0.0)
	_radiation.value = gauges.get("radiation", 0.0)
	var o2: float = gauges.get("o2", -1.0)
	_o2_row.visible = o2 >= 0.0
	if o2 >= 0.0:
		_o2.value = o2 * 100.0  # supply shown as remaining %
