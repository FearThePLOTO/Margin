extends Area2D
## Drag-and-drop cutscene. Plays `sequence` (a ui DialogueSequence .tres)
## through the MissionOverlay when the player walks in, or on level start
## (`autostart`). Player input is locked while it plays.
## Line text may use live tokens filled from SpaceWeather (real NASA DONKI):
##   {storm_level}  {storm_date}  {storm_source}
## reveal_nodes are hidden until the cutscene starts (e.g. OG pops out).
## activate_after are switched on when it ends (Area2D monitoring + visible),
## e.g. the surface radiation zone once the storm alert is given.

@export var sequence: Resource
@export var autostart := false
@export var autostart_delay_s := 0.8
@export var once := true
@export var reveal_nodes: Array[NodePath] = []
@export var hide_after: Array[NodePath] = []
@export var activate_after: Array[NodePath] = []
## Optional Marker2D the camera glides to while the scene plays, so every
## speaker is framed on screen (like a real game cutscene).
@export var camera_focus: NodePath

var played := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	for p in reveal_nodes:
		(get_node(p) as CanvasItem).hide()
	for p in activate_after:
		_set_active(get_node(p), false)
	if autostart and GameState.is_resuming():
		# CONTINUE from a checkpoint: the opening scene already happened.
		played = true
		for p in hide_after:
			(get_node(p) as CanvasItem).hide()
		for p in activate_after:
			_set_active(get_node(p), true)
	elif autostart:
		get_tree().create_timer(autostart_delay_s).timeout.connect(activate)


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(&"player"):
		activate()


func activate() -> void:
	if (played and once) or sequence == null:
		return
	played = true
	for p in reveal_nodes:
		var n := get_node(p)
		if n.has_method(&"appear"):
			n.call(&"appear")
		else:
			(n as CanvasItem).show()
	_focus_camera(true)
	EventBus.dialogue_finished.connect(_on_finished, CONNECT_ONE_SHOT)
	EventBus.dialogue_requested.emit(_resolved())


func _on_finished() -> void:
	_focus_camera(false)
	for p in hide_after:
		var n := get_node(p)
		if n.has_method(&"vanish"):
			n.call(&"vanish")
		else:
			(n as CanvasItem).hide()
	for p in activate_after:
		_set_active(get_node(p), true)


func _focus_camera(on: bool) -> void:
	var focus := get_node_or_null(camera_focus) as Node2D
	var player := get_tree().get_first_node_in_group(&"player") as Node2D
	if focus == null or player == null:
		return
	var cam := player.get_node_or_null(^"Camera2D") as Camera2D
	if cam == null:
		return
	var target := (focus.global_position - player.global_position) if on else Vector2.ZERO
	create_tween().tween_property(cam, "offset", target, 0.7) \
			.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)


func _set_active(n: Node, on: bool) -> void:
	if on and n.has_method(&"intensify"):
		n.call(&"intensify")
		return
	if n is Area2D:
		(n as Area2D).set_deferred("monitoring", on)
	if n is CanvasItem:
		(n as CanvasItem).visible = on


## Copy of the sequence with {tokens} replaced by the current space weather.
func _resolved() -> Resource:
	var w := SpaceWeather.info
	var tokens := {
		"storm_level": str(w.get("level", "MEDIUM")),
		"storm_date": str(w.get("date", "")),
		"storm_source": SpaceWeather.source_line(),
	}
	var copy: Resource = sequence.duplicate()
	var lines: Array = copy.get("lines").duplicate()
	lines.clear()
	for line: Resource in sequence.get("lines"):
		var l: Resource = line.duplicate()
		l.set("text", String(l.get("text")).format(tokens))
		lines.append(l)
	copy.set("lines", lines)
	return copy
