class_name InputMapEditor
extends MarginContainer


const INPUT_MAP_ACTION_EDITOR: PackedScene = preload("res://src/ui/lib/InputMapActionEditor.tscn")
const DIRECTION_KEYS: = ["w", "a", "s", "d", "up", "down", "left", "right"]
const DIRECTION_BUTTONS: = [12, 13, 14, 15]
const DIRECTION_SUFFIXES: = ["_up", "_down", "_left", "_right"]

signal input_add_requested(action, input_event)
signal input_remove_requested(action, input_event)

onready var action_editor_list: VBoxContainer = $Scroll/Margin/ActionEditorList
onready var input_popup: Popup = $InputMapCapturePopup


func _ready():
	input_popup.connect("about_to_show", self, "_on_popup_about_to_show")
	input_popup.connect("popup_hide", self, "_on_popup_hide")
	input_popup.connect("input_accepted", self, "_on_input_accepted")


func _on_popup_about_to_show():
	$Scroll.gamepad_scroll_enabled = false


func _on_popup_hide():
	$Scroll.gamepad_scroll_enabled = true


func _on_input_accepted(input_action: String, input_event: InputEvent):
	if is_direction_action(input_action) and is_direction_input_event(input_event):
		pass
	emit_signal("input_add_requested", input_action, input_event)


func _on_input_add_requested(input_action: String):
	input_popup.action = input_action
	input_popup.popup_centered()


func _on_input_remove_requested(input_action: String, input_event: InputEvent):
	emit_signal("input_remove_requested", input_action, input_event)


func is_direction_action(action: String) -> bool:
	var prefix: String
	for suffix in DIRECTION_SUFFIXES:
		if action.ends_with(suffix):
			prefix = action.trim_suffix(suffix)
			break

	if not prefix:
		return false

	for suffix in DIRECTION_SUFFIXES:
		if not InputMap.has_action(prefix + suffix):
			return false
	return true


func is_direction_input_event(event: InputEvent):
	if event is InputEventKey and OS.get_scancode_string(event.scancode) in DIRECTION_KEYS:
		return true
	elif event is InputEventJoypadMotion:
		return true
	elif event is InputEventJoypadButton and event.button_index in DIRECTION_BUTTONS:
		return true
	return false


func fix_focus_neighbours(action_editor: InputMapActionEditor):
	var count: int = action_editor_list.get_child_count()
	if count > 1:
		var index: = action_editor.get_index()
		if index > 0:
			var prev_button: Button = action_editor_list.get_child(index - 1).get_last_button()
			var button: Button = action_editor.get_first_button()
			prev_button.focus_neighbour_bottom = button.get_path()
			prev_button.focus_next = button.get_path()
			button.focus_neighbour_top = prev_button.get_path()
			button.focus_previous = prev_button.get_path()
		if index < count - 1:
			var next_button: Button = action_editor_list.get_child(index + 1).get_first_button()
			var button: Button = action_editor.get_last_button()
			button.focus_neighbour_bottom = next_button.get_path()
			button.focus_next = next_button.get_path()
			next_button.focus_neighbour_top = button.get_path()
			next_button.focus_previous = button.get_path()


func add_or_update_action(action: String, action_list: Array) -> InputMapActionEditor:
	var action_editor: InputMapActionEditor
	if action_editor_list.has_node("InputMapActionEditor_" + action):
		action_editor = action_editor_list.get_node("InputMapActionEditor_" + action)
		action_editor.action_list = action_list
	else:
		action_editor = add_action(action, action_list)
	fix_focus_neighbours(action_editor)
	return action_editor


func add_action(action: String, action_list: Array) -> InputMapActionEditor:
	var action_editor: InputMapActionEditor = INPUT_MAP_ACTION_EDITOR.instance()
	action_editor.name = "InputMapActionEditor_" + action
	action_editor_list.add_child(action_editor)
	action_editor.action = action
	action_editor.action_list = action_list
	action_editor.connect("input_add_requested", self, "_on_input_add_requested")
	action_editor.connect("input_remove_requested", self, "_on_input_remove_requested")
	fix_focus_neighbours(action_editor)
	return action_editor
