class_name PlayerAnimationMechanic
extends PlayerMechanic
## Animation resolver: picks the sprite animation from the player's resolved
## physics state each tick, and owns sprite facing. Runs AFTER move_and_slide()
## (and tether.post_move()) so on-floor / wall / velocity reads are final.
##
## Clips live in player.tscn's SpriteFrames (src/assets/char/astronaut_24.png,
## faces RIGHT, flip_h for left). Priority table (first match wins):
##   1. hurt timer active (if a "hurt" clip exists)  -> "hurt"
##   2. CLIMB / SWING                                -> freeze
##   3. jetpack thrusting                            -> "thrust"
##   4. takeoff timer (a jump just fired)            -> "takeoff" (one-shot)
##   5. airborne: rising fast / apex band / falling  -> "rise" / "apex" / "fall"
##   6. land timer (just touched down)               -> "land" (one-shot)
##   7. on floor, moving                             -> "walk"
##   8. otherwise                                    -> "idle"
## play() is only called when the resolved name CHANGES.

const FROZEN := &""
const MOVE_EPSILON_PXS := 5.0
## |vy| under this reads as the top of the arc.
const APEX_BAND_PXS := 40.0
const TAKEOFF_S := 0.16  # 3 frames @ 16 fps, then rise takes over
const LAND_S := 0.14     # 3 frames @ 16 fps (squash + recover)
## Celeste-style squash & stretch (sprite pivot is at the feet, see player.tscn).
const JUMP_STRETCH := Vector2(0.72, 1.3)
const LAND_SQUASH := Vector2(1.35, 0.7)
const SCALE_RECOVER := 9.0  # how fast the sprite springs back to 1:1

var _anim: AnimatedSprite2D
var _sprite: AnimatedSprite2D
var _hurt_timer := 0.0
var _takeoff := 0.0
var _land := 0.0
var _was_on_floor := true


func _init(p: Player) -> void:
	super(p)
	_anim = p.get_node(^"Sprite2D")
	_sprite = _anim


func process(delta: float) -> void:
	_hurt_timer = maxf(0.0, _hurt_timer - delta)
	_takeoff = maxf(0.0, _takeoff - delta)
	_land = maxf(0.0, _land - delta)
	var on_floor := player.is_on_floor()
	if player.move.jumped_this_tick:
		_takeoff = TAKEOFF_S
		_land = 0.0
		_sprite.scale = JUMP_STRETCH
	elif on_floor and not _was_on_floor:
		_land = LAND_S
		_takeoff = 0.0
		_sprite.scale = LAND_SQUASH
	_sprite.scale = _sprite.scale.lerp(Vector2.ONE, minf(1.0, SCALE_RECOVER * delta))
	_was_on_floor = on_floor

	var anim := _resolve(on_floor)
	if anim != FROZEN and _anim.animation != anim and _anim.sprite_frames.has_animation(anim):
		_anim.play(anim)
	_face()


func _resolve(on_floor: bool) -> StringName:
	if _hurt_timer > 0.0:
		return &"hurt"
	if player.state == Player.State.CLIMB or player.state == Player.State.SWING:
		return FROZEN
	if player.jetpack._thrusting:  # convention-private; read-only access
		return &"thrust"
	if not on_floor:
		if _takeoff > 0.0:
			return &"takeoff"
		if player.velocity.y < -APEX_BAND_PXS:
			return &"rise"
		if player.velocity.y <= APEX_BAND_PXS:
			return &"apex"
		return &"fall"
	if _land > 0.0:
		return &"land"
	if absf(player.velocity.x) > MOVE_EPSILON_PXS:
		return &"walk"
	return &"idle"


## Reserved damage hook: a future damage system calls this.
func play_hurt(duration := 0.5) -> void:
	_hurt_timer = duration


## Sprites face right. Leftward motion flips; climbing faces into the wall;
## swinging keeps the take-off facing.
func _face() -> void:
	if player.state == Player.State.CLIMB:
		if player.is_on_wall():
			_sprite.flip_h = player.get_wall_normal().x > 0.0
		return
	if player.state == Player.State.SWING:
		return
	var input_x := 0.0 if player.input_locked else Input.get_axis(&"move_left", &"move_right")
	if input_x != 0.0:
		_sprite.flip_h = input_x < 0.0
	elif absf(player.velocity.x) > MOVE_EPSILON_PXS:
		_sprite.flip_h = player.velocity.x < 0.0
