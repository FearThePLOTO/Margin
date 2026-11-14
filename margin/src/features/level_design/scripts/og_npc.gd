extends Area2D
## OG — the Old Geologist. A retired cave veteran who sits around the lava
## tubes and laughs at you. For no reason. Constantly. Louder when you die.
## Every line list is per-instance in the inspector: drag og_npc.tscn into a
## room and write what he says there. Emits nothing; only listens.
## (Swap _say() for the team dialog system once it lands on main.)

@export var greet_lines: Array[String] = ["HAH! Another rookie."]
@export var death_lines: Array[String] = ["HAHAHA!", "HEHEHE!", "Again?!", "Classic."]
@export var idle_lines: Array[String] = ["heh.", "hehehe...", "HA!"]
## He only reacts when the player is this close (px).
@export var hear_range_px := 340.0
## Random "laughing at nothing" interval, seconds (min, max).
@export var idle_laugh_every_s := Vector2(4.0, 9.0)
@export var bubble_time_s := 2.2

var _player: Node2D
var _idle_t := 0.0
var _bubble_t := 0.0
var _greeted := false

@onready var _sprite: AnimatedSprite2D = $Sprite
@onready var _bubble: Label = $Bubble


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	EventBus.player_died.connect(_on_player_died)
	EventBus.dialogue_line_started.connect(_on_dialogue_line)
	EventBus.dialogue_finished.connect(func() -> void: _sprite.play(&"idle"))
	_bubble.hide()
	_idle_t = randf_range(idle_laugh_every_s.x, idle_laugh_every_s.y)


func _process(delta: float) -> void:
	if _player == null:
		_player = get_tree().get_first_node_in_group(&"player") as Node2D
	if _player:
		_sprite.flip_h = _player.global_position.x < global_position.x
	if _bubble.visible:
		_bubble_t -= delta
		if _bubble_t <= 0.0:
			_bubble.hide()
			_sprite.play(&"idle")
	_idle_t -= delta
	if _idle_t <= 0.0:
		_idle_t = randf_range(idle_laugh_every_s.x, idle_laugh_every_s.y)
		if _near() and not _bubble.visible:
			_say(idle_lines)


## In cutscenes: cackle on OG's laugh lines, point while he talks.
func _on_dialogue_line(speaker: String, has_sfx: bool) -> void:
	if not visible:
		return
	if speaker == "OG":
		_sprite.play(&"laugh" if has_sfx else &"point")
	else:
		_sprite.play(&"idle")


## Magic entrance: a white flash that fades into OG standing on the ground.
func appear() -> void:
	show()
	modulate = Color(3, 3, 3, 0)
	var tw := create_tween()
	tw.tween_property(self, "modulate", Color(3, 3, 3, 1), 0.15)
	tw.tween_property(self, "modulate", Color.WHITE, 0.35)
	_sprite.play(&"laugh")


## Magic exit: flash white and fade away.
func vanish() -> void:
	var tw := create_tween()
	tw.tween_property(self, "modulate", Color(3, 3, 3, 1), 0.12)
	tw.tween_property(self, "modulate", Color(3, 3, 3, 0), 0.3)
	tw.tween_callback(hide)


func _near() -> bool:
	return _player != null and _player.global_position.distance_to(global_position) < hear_range_px


func _on_body_entered(body: Node2D) -> void:
	if not _greeted and body.is_in_group(&"player"):
		_greeted = true
		_say(greet_lines, &"point")


func _on_player_died() -> void:
	if _near():
		_say(death_lines)


func _say(lines: Array[String], anim := &"laugh") -> void:
	if lines.is_empty():
		return
	_bubble.text = lines.pick_random()
	_bubble.show()
	_bubble_t = bubble_time_s
	_sprite.play(anim)
