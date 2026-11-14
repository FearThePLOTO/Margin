extends AnimatableBody2D
## Falling platform: shakes briefly after the player lands on it, drops, then
## resets. A level-design prop only — no gauges, no resources, no mission logic.

@export var fall_delay_s := 0.6
@export var fall_speed_pxs := 200.0
@export var fall_time_s := 1.5
@export var reset_delay_s := 2.5

var _home := Vector2.ZERO
var _state := 0  # 0 idle, 1 shaking, 2 falling, 3 waiting to reset
var _t := 0.0

@onready var _shape: CollisionShape2D = $CollisionShape2D
@onready var _trigger: Area2D = $Trigger


## Optional art: an "Intact" sprite swapped for a "Cracked" one while it shakes.
@onready var _intact: CanvasItem = get_node_or_null(^"Intact")
@onready var _cracked: CanvasItem = get_node_or_null(^"Cracked")


func _ready() -> void:
	_home = position
	_trigger.body_entered.connect(_on_trigger)
	EventBus.player_respawned.connect(_reset)
	_set_cracked(false)


func _set_cracked(on: bool) -> void:
	if _intact:
		_intact.visible = not on
	if _cracked:
		_cracked.visible = on


## Dying puts every platform back at once (Celeste-style room reset).
func _reset() -> void:
	position = _home
	show()
	_shape.set_deferred("disabled", false)
	_set_cracked(false)
	_state = 0
	_t = 0.0


func _on_trigger(body: Node2D) -> void:
	if _state == 0 and body.is_in_group(&"player"):
		_state = 1
		_t = 0.0
		_set_cracked(true)


func _physics_process(delta: float) -> void:
	_t += delta
	match _state:
		1:
			position.x = _home.x + sin(_t * 70.0)  # visible wobble = the warning
			if _t >= fall_delay_s:
				_state = 2
				_t = 0.0
		2:
			position.y += fall_speed_pxs * delta
			if _t >= fall_time_s:
				_state = 3
				_t = 0.0
				hide()
				_shape.set_deferred("disabled", true)
		3:
			if _t >= reset_delay_s:
				position = _home
				show()
				_shape.set_deferred("disabled", false)
				_set_cracked(false)
				_state = 0
				_t = 0.0
				if _trigger.has_overlapping_bodies():
					_state = 1
					_set_cracked(true)
