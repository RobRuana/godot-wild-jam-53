class_name InputMapCapturePopup
extends Popup


signal input_accepted(action, input_event)

var action: String setget set_action
var input_event: InputEvent setget set_input_event
var focused_control: Control

onready var accept_button: Button = $Center/Panel/Margin/VBox/HBox/AcceptButton
onready var cancel_button: Button = $Center/Panel/Margin/VBox/HBox/CancelButton
onready var input_label: Label = $Center/Panel/Margin/VBox/InputLabel
onready var action_label: Label = $Center/Panel/Margin/VBox/ActionLabel


func set_action(value: String):
	action = value
	if has_node("Center/Panel/Margin/VBox/ActionLabel"):
		action_label.text = action.capitalize()


func set_input_event(value: InputEvent):
	if not value:
		input_event = null
		toggle_accept_button(false)
		set_input_text("Press keyboard or controller button...")
	elif value.is_pressed():
		if value is InputEventKey:
			input_event = value
			get_tree().set_input_as_handled()
			toggle_accept_button(true)
			set_input_text(Settings.input_event_to_text(input_event))
		elif not input_event and (
			value is InputEventJoypadButton or (value is InputEventJoypadMotion and int(round(value.axis_value)))
		):
			input_event = value
			get_tree().set_input_as_handled()
			toggle_accept_button(true)
			set_input_text(Settings.input_event_to_text(input_event))


func set_input_text(text: String):
	input_label.text = text


func _ready():
	set_process_input(false)
	connect("about_to_show", self, "_on_about_to_show")
	connect("popup_hide", self, "_on_popup_hide")


func _input(event: InputEvent):
	self.input_event = event


func is_joy_event(event: InputEvent):
	return event is InputEventJoypadButton or event is InputEventJoypadMotion


func toggle_accept_button(enabled: bool):
	accept_button.disabled = not enabled
	if enabled:
		accept_button.focus_mode = Control.FOCUS_ALL
	else:
		accept_button.focus_mode = Control.FOCUS_NONE
		accept_button.release_focus()


func _on_about_to_show():
	self.input_event = null
	focused_control = get_focus_owner()
	if focused_control:
		focused_control.release_focus()
	set_process_input(true)


func _on_popup_hide():
	set_process_input(false)
	if focused_control:
		focused_control.grab_focus()
		focused_control = null


func _on_cancel_button_pressed():
	self.hide()


func _on_accept_button_pressed():
	if input_event:
		emit_signal("input_accepted", action, input_event)
	self.hide()
