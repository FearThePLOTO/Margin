class_name PlayerAnimationMechanic
extends PlayerMechanic
## Animation resolver: picks the sprite animation from the player's resolved
## physics state each tick, and owns sprite facing. Runs AFTER move_and_slide()
## (and tether.post_move()) so on-floor / wall / velocity reads are final for
## the tick.
##
## Resolution is a priority table (first match wins):
##   1. hurt timer active         -> "hurt" (reserved slot, see play_hurt)
##   2. CLIMB / SWING / thrust    -> freeze (keep whatever is playing)
##   3. airborne, vy < 0          -> "jump" (hold)
##   4. airborne, vy > 0          -> "fall" (hold)
##   5. on floor, moving          -> "run"
##   6. otherwise                 -> "idle"
##
## play() is only called when the resolved name CHANGES, so holds never
## restart mid-state. Climb/swing/thrust have no art yet — they freeze the
## current animation (usually idle) until real clips exist; their rows are
## already in place, real animations drop in by naming them. hurt is not
## wired to anything: there is no damage system yet — when one exists it
## calls play_hurt(). After mission_over the coordinator stops ticking, so
## the sprite naturally freezes on its last frame.

const FROZEN := &""  # sentinel: keep the current animation untouched
const MOVE_EPSILON_PXS := 5.0  # below this horizontal speed we are standing

var _anim: AnimationPlayer
var _sprite: Sprite2D
var _hurt_timer := 0.0


func _init(p: Player) -> void:
	super(p)
	_anim = p.get_node(^"AnimationPlayer")
	_sprite = p.get_node(^"Sprite2D")
	# Texture swaps stay in lockstep with the 60 Hz simulation.
	_anim.callback_mode_process = AnimationMixer.ANIMATION_CALLBACK_MODE_PROCESS_PHYSICS


func process(delta: float) -> void:
	_hurt_timer = maxf(0.0, _hurt_timer - delta)
	var anim := _resolve()
	if anim != FROZEN and _anim.current_animation != String(anim):
		_anim.play(anim)
	_face()


func _resolve() -> StringName:
	if _hurt_timer > 0.0:
		return &"hurt"
	if player.state == Player.State.CLIMB or player.state == Player.State.SWING:
		return FROZEN
	if player.jetpack._thrusting:  # convention-private; read-only access
		return FROZEN
	if not player.is_on_floor():
		if player.velocity.y < 0.0:
			return &"jump"
		if player.velocity.y > 0.0:
			return &"fall"
		return FROZEN  # apex: hold the previous frame
	if absf(player.velocity.x) > MOVE_EPSILON_PXS:
		return &"run"
	return &"idle"


## Reserved damage hook: nothing damages the player yet. A future health /
## damage system calls this; hurt then overrides the table for `duration`.
func play_hurt(duration := 0.5) -> void:
	_hurt_timer = duration


## Sprites face right. Leftward motion flips; climbing faces into the wall
## (opposite its normal); swinging keeps the take-off facing.
func _face() -> void:
	if player.state == Player.State.CLIMB:
		if player.is_on_wall():
			_sprite.flip_h = player.get_wall_normal().x > 0.0
		return
	if player.state == Player.State.SWING:
		return
	if absf(player.velocity.x) > MOVE_EPSILON_PXS:
		_sprite.flip_h = player.velocity.x < 0.0
