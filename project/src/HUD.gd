class_name HUD
extends MarginContainer


#func _ready():
#	Events.connect("player_ready", self, "_on_player_ready")


func _on_player_ready(player):
	player.connect("player_health_changed", self, "_on_player_health_changed")
	player.connect("player_zoom_changed", self, "_on_player_zoom_changed")
	player.connect("player_zoom_recovery", self, "_on_player_zoom_recovery")
	player.connect("letter_inside_goal", self, "_on_letter_inside_goal")


func _on_player_health_changed(_player: Player, value: int, old_value: int):
	$HealthMeter.health = value


func _on_player_zoom_changed(_player: Player, value: float, old_value: float):
	$ZoomMargin/ZoomPanel/ZoomMeter.value = value
	if is_equal_approx(value, 100.0) and not Input.is_action_pressed("zoom"):
		$Fader.fade_to_transparent($ZoomMargin, 0.25)
	elif is_equal_approx(old_value, 100.0):
		$Fader.fade_to_opaque($ZoomMargin, 0.25)


func _on_player_zoom_recovery(_player: Player, value: bool):
	if value:
		$ZoomMargin/ZoomPanel/ZoomMeter.modulate = Color(0.8, 0.2, 0.2, 1.0)
	else:
		$Tween.remove($ZoomMargin/ZoomPanel/ZoomMeter)
		$Tween.interpolate_property($ZoomMargin/ZoomPanel/ZoomMeter, "modulate", null, Color.black, 0.25, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		$Tween.start()


func _on_letter_inside_goal(letter: LetterSprite):
	var child = $LetterContainer.get_letter(letter.character_index)
	child.modulate = Color(0.0, 0.8, 0.0, 1.0)
