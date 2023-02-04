class_name PopScreenButton
extends Button


const SHORTCUT_UI_CANCEL: ShortCut = preload("res://src/ui/lib/shortcut_ui_cancel.tres")

export var hide_on_html5: bool = false


func _ready():
	if hide_on_html5 and OS.get_name() == "HTML5":
		visible = false
	else:
		shortcut = SHORTCUT_UI_CANCEL
		shortcut_in_tooltip = false
		connect("pressed", self, "_on_button_pressed")


func get_ui_controller():
	var parent = get_parent()
	while parent and not parent is UIController:
		parent = parent.get_parent()
	return parent


func _on_button_pressed():
	var controller = get_ui_controller()
	if controller:
		controller.pop_screen()
