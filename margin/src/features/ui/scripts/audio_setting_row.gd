extends HBoxContainer
## One labelled horizontal volume control. The label button owns keyboard focus
## and the shared selection underline; the slider owns the discrete level.

signal level_changed(level: int)

const VolumeSliderScript = preload("res://src/features/ui/scripts/volume_slider.gd")

@export var label_text := "MUSIC":
	set(value):
		label_text = value
		if is_node_ready():
			label_button.text = value

@export_range(0, 10, 1) var level: int = 7:
	set(value):
		level = clampi(value, 0, 10)
		if is_node_ready():
			slider.level = level

@onready var label_button: Button = %LabelButton
@onready var slider: VolumeSliderScript = %Slider

func _ready() -> void:
	label_button.text = label_text
	slider.level = level
	slider.activated.connect(_on_slider_activated)
	slider.level_changed.connect(_on_slider_level_changed)
	slider.mouse_entered.connect(_on_slider_mouse_entered)

func set_selected(value: bool) -> void:
	slider.selected = value

func _on_slider_activated() -> void:
	label_button.grab_focus()

func _on_slider_mouse_entered() -> void:
	if label_button.focus_mode != Control.FOCUS_NONE:
		label_button.grab_focus()

func _on_slider_level_changed(value: int) -> void:
	level = value
	level_changed.emit(value)
