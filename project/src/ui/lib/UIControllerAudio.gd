class_name UIControllerAudio
extends Node


export var focus_follows_mouse: bool = true


func _ready():
	var parent = get_parent()
	if parent is UIController:
		yield(parent, "ready")
		parent.connect("pop_controller_requested", self, "_on_pop_controller_requested", [], CONNECT_ONESHOT)
		parent.connect("focus_entered_control", self, "_on_focus_entered")
		parent.connect("mouse_entered_control", self, "_on_mouse_entered")
		parent.connect("focusable_control_added", self, "bind_control")
		parent.connect("focusable_control_removed", self, "unbind_control")
		for control in Global.get_focusable_controls(parent):
			bind_control(control)


func _on_pop_controller_requested(controller: UIController):
	controller.disconnect("focus_entered_control", self, "_on_focus_entered")
	controller.disconnect("mouse_entered_control", self, "_on_mouse_entered")
	controller.disconnect("focusable_control_added", self, "bind_control")
	controller.disconnect("focusable_control_removed", self, "unbind_control")
	for control in Global.get_focusable_controls(controller):
		unbind_control(control)


func bind_control(control: Control):
	if control is BaseButton:
		if control is PopScreenButton:
			if not control.is_connected("pressed", self, "_on_pop_screen_button_pressed"):
				control.connect("pressed", self, "_on_pop_screen_button_pressed", [control])
		else:
			if not control.is_connected("pressed", self, "_on_button_pressed"):
				control.connect("pressed", self, "_on_button_pressed", [control])


func unbind_control(control: Control):
	if control is BaseButton:
		if control is PopScreenButton:
			if control.is_connected("pressed", self, "_on_pop_screen_button_pressed"):
				control.disconnect("pressed", self, "_on_pop_screen_button_pressed")
		else:
			if control.is_connected("pressed", self, "_on_button_pressed"):
				control.disconnect("pressed", self, "_on_button_pressed")


func _on_mouse_entered(control: Control):
	if focus_follows_mouse and control.focus_mode == Control.FOCUS_ALL:
		control.grab_focus()


func _on_focus_entered(control: Control):
	var controller: UIController = get_parent()
	if !controller.transitioning and controller.visible and controller.modulate.a > 0.0:
		play_focus_audio()


func _on_button_pressed(control: Control):
	var controller: UIController = get_parent()
	if !controller.transitioning and controller.visible and controller.modulate.a > 0.0:
		play_menu_select_audio()


func _on_pop_screen_button_pressed(control: Control):
	var controller: UIController = get_parent()
	if !controller.transitioning and controller.visible and controller.modulate.a > 0.0:
		play_menu_cancel_audio()


func play_focus_audio():
	if !$FocusAudio.playing:
		$FocusAudio.play()


func play_menu_select_audio():
	if !$MenuSelectAudio.playing:
		$MenuSelectAudio.play()


func play_menu_cancel_audio():
	if !$MenuCancelAudio.playing:
		$MenuCancelAudio.play()
