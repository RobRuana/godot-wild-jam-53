extends Node

const SETTINGS_PATH: = "user://settings.cfg"
const DEFAULT_SETTINGS: = """
[audio_volume]
Master=100.0
Music=70.0
Effects=70.0
Interface=50.0

[video]
window_mode=0
window_borderless=false
vsync_enabled=true

[input]
"""

enum WindowMode {Normal, Borderless, Fullscreen}

signal setting_changed
signal initialized

var is_initialized: bool = false
var default_settings: ConfigFile = ConfigFile.new()
var settings: ConfigFile = ConfigFile.new()


func _init():
	_populate_defaults(default_settings)

	var file: = File.new()
	if file.file_exists(SETTINGS_PATH):
		settings.load(SETTINGS_PATH)
	else:
		_populate_defaults(settings)
		settings.save(SETTINGS_PATH)

	for section in settings.get_sections():
		for key in settings.get_section_keys(section):
			var value = settings.get_value(section, key)
			_on_setting_changed(section, key, value)

	is_initialized = true
	emit_signal("initialized")


func _populate_defaults(config: ConfigFile):
	config.parse(DEFAULT_SETTINGS)
	for action in InputMap.get_actions():
		if is_editable_input_action(action):
			var action_dict: Dictionary = {"events": []}
			for input_event in InputMap.get_action_list(action):
				action_dict["events"].push_back(input_event)
			config.set_value("input", action, action_dict)


func once_initialized(target: Object, method: String):
	if is_initialized:
		target.call_deferred(method)
	else:
		connect("initialized", target, method, [], CONNECT_ONESHOT)


func config_file_to_string(config: ConfigFile, section: String = "") -> String:
	var lines = PoolStringArray()
	if section:
		lines.push_back("[%s]" % section)
		if config.has_section(section):
			for key in config.get_section_keys(section):
				var value = config.get_value(section, key)
				lines.push_back("%s=%s" % [key, value])
			lines.push_back("")
	else:
		for section in config.get_sections():
			lines.push_back(config_file_to_string(config, section))
	return lines.join("\n")


func to_string(section: String = "") -> String:
	return config_file_to_string(settings, section)


func dump():
	print(to_string())


func dump_section(section: String):
	print(to_string(section))


func get_sections() -> PoolStringArray:
	return settings.get_sections()


func get_section_keys(section: String) -> PoolStringArray:
	if settings.has_section(section):
		return settings.get_section_keys(section)
	return PoolStringArray()


func get_value(section: String, key: String, default_value = null):
	if settings.has_section_key(section, key):
		return settings.get_value(section, key, default_value)
	return default_value


func set_value(section: String, key: String, value):
	var old_value = settings.get_value(section, key) if settings.has_section_key(section, key) else null
	settings.set_value(section, key, value)
	if value != old_value:
		_on_setting_changed(section, key, value, old_value)
		emit_signal("setting_changed", section, key, value, old_value)


func reset_section(section: String):
	for key in default_settings.get_section_keys(section):
		var value = default_settings.get_value(section, key)
		set_value(section, key, value)


func save():
	settings.save(SETTINGS_PATH)


func _on_setting_changed(section, key, value, old_value = null):
	if section == "audio_volume":
		var audio_bus_index: = AudioServer.get_bus_index(key)
		if audio_bus_index >= 0:
			var volume: = max(linear2db(value / 100.0), -80.0)
			AudioServer.set_bus_volume_db(audio_bus_index, volume)
			# To do the reverse:
			# var volume: = AudioServer.get_bus_volume_db(audio_bus_index)
			# var value: = round(min(db2linear(volume) * 100.0, 100.0))

	elif section == "video":
		if key == "window_mode":
			if value == WindowMode.Normal:
				OS.window_fullscreen = false
				OS.window_borderless = false
				settings.set_value("video", "window_borderless", false)
			elif value == WindowMode.Borderless:
				OS.window_fullscreen = false
				OS.window_borderless = true
				settings.set_value("video", "window_borderless", true)
			elif value == WindowMode.Fullscreen:
				OS.window_borderless = false
				OS.window_fullscreen = true
		elif key == "vsync_enabled":
			OS.vsync_enabled = value

	elif section == "input":
		if value == null:
			if InputMap.has_action(key):
				InputMap.action_erase_events(key)
		else:
			if not InputMap.has_action(key):
				InputMap.add_action(key)
			if "deadzone" in value:
				InputMap.action_set_deadzone(key, value["deadzone"])
			for new_input_event in value["events"]:
				if not InputMap.action_has_event(key, new_input_event):
					InputMap.action_add_event(key, new_input_event)
			for old_input_event in InputMap.get_action_list(key):
				if not array_has_input_event(value["events"], old_input_event):
					InputMap.action_erase_event(key, old_input_event)

# =============================================================
# Input settings helpers
# =============================================================

func input_event_to_text(event: InputEvent) -> String:
	if event is InputEventKey:
		return "Keyboard: %s" % event.as_text()
	elif event is InputEventJoypadButton:
		if Input.is_joy_known(event.device):
			return "%s: %s" % [Input.get_joy_name(event.device), Input.get_joy_button_string(event.button_index)]
		else:
			return "Controller: Button %s" % event.button_index
	elif event is InputEventJoypadMotion:
		var axis_value: int = int(round(event.axis_value))
		if Input.is_joy_known(event.device):
			var text: = "%s: %s" % [Input.get_joy_name(event.device), Input.get_joy_axis_string(event.axis)]
			if text.ends_with("X"):
				text = text.rstrip(" X")
				if axis_value > 0:
					text += " ⇨"
				else:
					text += " ⇦"
			else:
				text = text.rstrip(" Y")
				if axis_value > 0:
					text += " ⇩"
				else:
					text += " ⇧"
			return text
		else:
			return "Controller: Axis %s Direction %s" % [event.axis, axis_value]
	elif event:
		return event.to_string()
	return ""


func is_editable_input_action(action: String) -> bool:
	return not action.begins_with("ui_") and (not action.begins_with("debug_") or OS.is_debug_build())


func get_input_actions() -> Array:
	return settings.get_section_keys("input") as Array


func get_input_action_list(action: String) -> Array:
	var action_dict = settings.get_value("input", action)
	if action_dict and "events" in action_dict:
		return action_dict["events"]
	return []


func input_action_add_event(action: String, event: InputEvent):
	var action_dict: Dictionary = settings.get_value("input", action, {}).duplicate(true)
	if not "events" in action_dict:
		action_dict["events"] = []
	if not event in action_dict["events"]:
		action_dict["events"].push_back(event)
	set_value("input", action, action_dict)


func input_action_erase_event(action: String, event: InputEvent):
	var action_dict: Dictionary = settings.get_value("input", action, {}).duplicate(true)
	if not "events" in action_dict:
		action_dict["events"] = []
	action_dict["events"].erase(event)
	set_value("input", action, action_dict)


func array_has_input_event(a: Array, e: InputEvent) -> bool:
	for event in a:
		if equals_input_events(event, e):
			return true
	return false


func equals_input_events(e1: InputEvent, e2: InputEvent) -> bool:
	if e1 is InputEventKey and e2 is InputEventKey:
		return equals_input_event_keys(e1, e2)
	elif e1 is InputEventMouseButton and e2 is InputEventMouseButton:
		return equals_input_event_mouse_buttons(e1, e2)
	elif e1 is InputEventJoypadMotion and e2 is InputEventJoypadMotion:
		return equals_input_event_joypad_motion(e1, e2)
	elif e1 is InputEventJoypadButton and e2 is InputEventJoypadButton:
		return equals_input_event_joypad_button(e1, e2)
	elif e1 is InputEventAction and e2 is InputEventAction:
		return equals_input_event_action(e1, e2)
	return false


func equals_input_event_devices(e1: InputEvent, e2: InputEvent) -> bool:
	if not e1 or not e2:
		return false
	var device1: int = e1.get_device()
	var device2: int = e2.get_device()
	return device1 == device2 or device1 == InputEvent.ALL_DEVICES or device2 == InputEvent.ALL_DEVICES


func equals_input_event_keys(e1: InputEventKey, e2: InputEventKey) -> bool:
	if not equals_input_event_devices(e1, e2):
		return false
	return e1.get_scancode_with_modifiers() == e2.get_scancode_with_modifiers() and e1.pressed == e2.pressed


func equals_input_event_mouse_buttons(e1: InputEventMouseButton, e2: InputEventMouseButton) -> bool:
	if not equals_input_event_devices(e1, e2):
		return false
	return e1.button_index == e2.button_index and e1.pressed == e2.pressed and e1.doubleclick == e2.doubleclick


func equals_input_event_joypad_motion(e1: InputEventJoypadMotion, e2: InputEventJoypadMotion) -> bool:
	if not equals_input_event_devices(e1, e2):
		return false
	return e1.axis == e2.axis and sign(e1.axis_value) == sign(e2.axis_value)


func equals_input_event_joypad_button(e1: InputEventJoypadButton, e2: InputEventJoypadButton) -> bool:
	if not equals_input_event_devices(e1, e2):
		return false
	return e1.button_index == e2.button_index and e1.pressed == e2.pressed


func equals_input_event_action(e1: InputEventAction, e2: InputEventAction) -> bool:
	if not equals_input_event_devices(e1, e2):
		return false
	return e1.action == e2.action and e1.pressed == e2.pressed
