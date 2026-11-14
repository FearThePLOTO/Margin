extends Button
## Reusable focus-on-hover behavior for menu-style options.
##
## Focus is the single source of truth for the selection underline. Hovering
## moves focus to the hovered option, so only one underline can be visible and
## keyboard activation always matches the underline the player sees.

func _ready() -> void:
	focus_mode = Control.FOCUS_ALL
	mouse_entered.connect(_on_mouse_entered)

func _on_mouse_entered() -> void:
	if focus_mode != Control.FOCUS_NONE and not has_focus():
		grab_focus()
