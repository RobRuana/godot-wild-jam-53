extends UIScreen


onready var window_mode: OptionButton = $Margin/VBox/VBoxCenter/MarginWindowMode/HBox/WindowModeButton
onready var vsync_enabled: CheckButton = $Margin/VBox/VBoxCenter/MarginVsync/VsyncEnabledButton

func _ready():
	for name in Settings.WindowMode:
		window_mode.add_item(name, Settings.WindowMode[name])


func will_push_screen():
	Settings.once_initialized(self, "_on_settings_initialized")
	Settings.connect("setting_changed", self, "_on_setting_changed")
	.will_push_screen()


func did_pop_screen():
	Settings.save()
	Settings.disconnect("setting_changed", self, "_on_setting_changed")
	.did_pop_screen()


func _on_reset_button_pressed():
	Settings.reset_section("video")


func _on_settings_initialized():
	window_mode.select(Settings.get_value("video", "window_mode", 0))
	vsync_enabled.pressed = Settings.get_value("video", "vsync_enabled", false)


func _on_setting_changed(section, key, value, old_value):
	if section == "video":
		if key == "window_mode":
			window_mode.select(value)
		elif key == "vsync_enabled":
			vsync_enabled.pressed = value


func _on_window_mode_item_selected(index: int):
	Settings.set_value("video", "window_mode", index)


func _on_vsync_button_toggled(pressed: bool):
	Settings.set_value("video", "vsync_enabled", pressed)
