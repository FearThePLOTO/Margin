extends Sprite2D
## Max's lander. With `land_on_start` it touches down when the level begins:
## thruster flame on the way down, a dust burst and a small camera bump on
## landing, then Max steps out (player input is locked meanwhile).

@export var land_on_start := true
@export var fall_height := 150.0
@export var land_time_s := 2.6

@onready var _flame: CPUParticles2D = $Flame
@onready var _burst: CPUParticles2D = $DustBurst


func _ready() -> void:
	_flame.emitting = false
	if land_on_start and not GameState.is_resuming():
		_land.call_deferred()


func _land() -> void:
	var player := get_tree().get_first_node_in_group(&"player") as Node2D
	if player:
		player.hide()
	EventBus.cutscene_started.emit()
	var home := position
	position.y -= fall_height
	_flame.emitting = true
	var tw := create_tween()
	tw.tween_property(self, "position", home, land_time_s).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tw.finished
	_flame.emitting = false
	_burst.restart()
	if player:
		var cam := player.get_node_or_null(^"Camera2D") as Camera2D
		if cam:
			var bump := create_tween()
			bump.tween_property(cam, "offset", Vector2(0, 3), 0.05)
			bump.tween_property(cam, "offset", Vector2.ZERO, 0.2)
	await get_tree().create_timer(0.7).timeout
	if player:
		player.show()
	EventBus.cutscene_ended.emit()
