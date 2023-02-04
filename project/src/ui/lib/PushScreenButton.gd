class_name PushScreenButton
extends Button


export var screen: String
export var transition: Resource
export var transition_properties: Dictionary

export var hide_on_html5: bool = false


func _ready():
	if hide_on_html5 and OS.get_name() == "HTML5":
		visible = false
	else:
		connect("pressed", self, "_on_button_pressed")


func get_ui_controller():
	var parent = get_parent()
	while parent and not parent is UIController:
		parent = parent.get_parent()
	return parent


func _on_button_pressed():
	var controller = get_ui_controller()
	if controller:
		controller.push_screen(screen, transition, transition_properties)
