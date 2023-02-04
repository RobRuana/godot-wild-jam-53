class_name InputMapActionEditor
extends MarginContainer


const INPUT_MAP_INPUT_ITEM: PackedScene = preload("res://src/ui/lib/InputMapInputItem.tscn")


signal input_add_requested(action)
signal input_remove_requested(action, input_event)


var action: String setget set_action
var action_list: Array setget set_action_list
var focus_index: int = -1

onready var add_input_button: Button = $VBox/HBox/AddInputButton
onready var input_list: VBoxContainer = $VBox/Margin/InputList
onready var help_label: Label = $VBox/HBox/HelpLabel


func set_action(value: String):
	action = value
	if add_input_button:
		add_input_button.text = action.capitalize()


func set_action_list(value: Array):
	clear_input_items()
	for input_event in value:
		add_input_item(input_event)
	if focus_index >= 0:
		if value.size() > 0:
			if focus_index >= value.size():
				focus_index = value.size() - 1
			input_list.get_child(focus_index).remove_input_button.grab_focus()
		else:
			add_input_button.grab_focus()
		focus_index = -1


func get_first_button() -> Button:
	return add_input_button


func get_last_button() -> Button:
	if input_list.get_child_count() > 0:
		return Global.get_last_child(input_list).remove_input_button
	return add_input_button


func _ready():
	add_input_button.connect("focus_entered", help_label, "set_visible", [true])
	add_input_button.connect("focus_exited", help_label, "set_visible", [false])


func _on_setting_changed(section, key, value, old_value):
	if section == "input" and key == action:
		clear_input_items()
		for input_event in Settings.get_input_action_list(action):
			add_input_item(input_event)


func _on_add_input_button_pressed():
	emit_signal("input_add_requested", action)


func _on_input_remove_requested(input_item: InputMapInputItem):
	focus_index = input_item.get_index()
	emit_signal("input_remove_requested", action, input_item.input_event)


func add_input_item(input_event: InputEvent):
	var input_item: InputMapInputItem = INPUT_MAP_INPUT_ITEM.instance()
	input_list.add_child(input_item)
	input_item.input_event = input_event
	input_item.connect("input_remove_requested", self, "_on_input_remove_requested", [input_item], Control.CONNECT_ONESHOT)

	var count: int = input_list.get_child_count()
	var previous_button: Control = add_input_button if count == 1 else input_list.get_child(count - 2).remove_input_button
	var button: Button = input_item.remove_input_button
	previous_button.focus_neighbour_bottom = button.get_path()
	previous_button.focus_next = button.get_path()
	button.focus_neighbour_top = previous_button.get_path()
	button.focus_previous = previous_button.get_path()


func clear_input_items():
	while input_list.get_child_count() > 0:
		var child: Node = input_list.get_child(0)
		input_list.remove_child(child)
		child.queue_free()
