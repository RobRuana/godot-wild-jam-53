class_name InputMapInputItem
extends MarginContainer


signal input_remove_requested

onready var remove_input_button: Button = $HBox/InputRemoveButton
onready var help_label: Label = $HBox/HelpLabel
var input_event: InputEvent setget set_input_event


func set_input_event(value: InputEvent):
	input_event = value
	if remove_input_button:
		remove_input_button.text = Settings.input_event_to_text(input_event)


func _ready():
	remove_input_button.connect("pressed", self, "emit_signal", ["input_remove_requested"])
	remove_input_button.connect("focus_entered", help_label, "set_visible", [true])
	remove_input_button.connect("focus_exited", help_label, "set_visible", [false])
