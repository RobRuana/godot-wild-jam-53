class_name GamepadScrollContainer
extends ScrollContainer


export var gamepad_scroll_enabled: bool = true
export var gamepad_scroll_speed: float = 5.0


func _process(delta: float):
	if gamepad_scroll_enabled:
		var strength: = Input.get_action_strength("ui_page_down") - Input.get_action_strength("ui_page_up")
		scroll_vertical += int(gamepad_scroll_speed * strength)
