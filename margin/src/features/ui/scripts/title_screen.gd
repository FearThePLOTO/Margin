extends Control
## Title screen: the first valid key press or mouse click starts a rapid
## retro-style prompt flash, then the screen advances to the Main Menu exactly
## once. The idle prompt keeps its existing smooth opacity pulse.

signal continue_requested

const _PULSE_SPEED := 2.0
const _PULSE_MIN_ALPHA := 0.15
const _FLASH_DURATION := 1.0
const _FLASH_FREQUENCY := 8.0
const _FLASH_EDGE := 0.18
const _FLASH_MIN_ALPHA := 0.04

@onready var _prompt: Label = $Center/Layout/Prompt

var _elapsed := 0.0
var _armed := true
var _flashing := false
var _flash_elapsed := 0.0
var _transitioned := false

func _process(delta: float) -> void:
	if not is_visible_in_tree():
		return

	if _flashing:
		_update_flash(delta)
		return

	if not _armed:
		return

	_elapsed += delta
	# Keep the prompt's white RGB and animate only opacity. A cosine gives equal
	# fade-out and fade-in halves, with no abrupt return at either end.
	var phase := 0.5 + 0.5 * cos(_elapsed * _PULSE_SPEED)
	var alpha := lerpf(_PULSE_MIN_ALPHA, 1.0, phase)
	_prompt.modulate = Color(1.0, 1.0, 1.0, alpha)

func _input(event: InputEvent) -> void:
	if not _armed or not is_visible_in_tree():
		return

	var key := event as InputEventKey
	if key != null and key.pressed and not key.echo:
		_begin_flash()
		return

	var mouse := event as InputEventMouseButton
	if mouse != null and mouse.pressed:
		_begin_flash()

func _begin_flash() -> void:
	if not _armed:
		return

	_armed = false
	_flashing = true
	_flash_elapsed = 0.0
	# Start on a bright frame. Only the alpha changes; the prompt's position,
	# size, font, and white RGB stay untouched.
	_prompt.modulate = Color.WHITE
	set_process(true)
	get_viewport().set_input_as_handled()

func _update_flash(delta: float) -> void:
	_flash_elapsed = minf(_flash_elapsed + delta, _FLASH_DURATION)
	var cycle := fmod(_flash_elapsed * _FLASH_FREQUENCY, 1.0)
	var pulse: float
	if cycle < 0.5:
		pulse = 1.0 - smoothstep(0.0, _FLASH_EDGE, cycle)
	else:
		pulse = smoothstep(0.5, 0.5 + _FLASH_EDGE, cycle)
	var alpha := lerpf(_FLASH_MIN_ALPHA, 1.0, pulse)
	_prompt.modulate = Color(1.0, 1.0, 1.0, alpha)

	if _flash_elapsed >= _FLASH_DURATION:
		_finish_flash()

func _finish_flash() -> void:
	if not _flashing:
		return

	_flashing = false
	_prompt.modulate = Color.WHITE
	set_process(false)
	if _transitioned:
		return
	_transitioned = true
	continue_requested.emit()
