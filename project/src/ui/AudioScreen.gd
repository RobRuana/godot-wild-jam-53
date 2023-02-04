extends UIScreen


onready var volume_sliders: = {
	"Master": $Margin/VBox/VBoxCenter/MarginMain/HBoxMain/MainVolume,
	"Music": $Margin/VBox/VBoxCenter/MarginMusic/HBoxMusic/MusicVolume,
	"Effects": $Margin/VBox/VBoxCenter/MarginEffects/HBoxEffects/EffectsVolume,
	"Interface": $Margin/VBox/VBoxCenter/MarginInterface/HBoxInterface/InterfaceVolume,
}


onready var audio_pops: = {
	"Master": $MasterPop,
	"Music": $MusicPop,
	"Effects": $EffectsPop,
	"Interface": $InterfacePop,
}


func will_push_screen():
	Settings.once_initialized(self, "_on_settings_initialized")
	Settings.connect("setting_changed", self, "_on_setting_changed")
	.will_push_screen()


func did_pop_screen():
	Settings.save()
	Settings.disconnect("setting_changed", self, "_on_setting_changed")
	.did_pop_screen()


func _on_volume_slider_value_changed(value: float, key: String):
	Settings.set_value("audio_volume", key, value)
	if not transitioning and volume_sliders[key].has_focus():
		audio_pops[key].play()


func _on_reset_button_pressed():
	Settings.reset_section("audio_volume")


func _on_settings_initialized():
	for key in volume_sliders.keys():
		volume_sliders[key].value = Settings.get_value("audio_volume", key, 100.0)


func _on_setting_changed(section, key, value, old_value):
	if section == "audio_volume":
		volume_sliders[key].value = value
