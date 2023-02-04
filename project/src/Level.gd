class_name Level
extends Node2D


signal intro_completed

const LETTER_SPRITE: PackedScene = preload("res://src/LetterSprite.tscn")
const OFFSCREEN_POINTER: PackedScene = preload("res://src/utils/OffscreenPointer.tscn")
const TYPEWRITER_BELL_AUDIO: AudioStream = preload("res://assets/audio/typewriter_bell_01.wav")
const TYPEWRITER_CARRIAGE_RETURN_AUDIO: AudioStream = preload("res://assets/audio/typewriter_carriage_return_01.wav")

var is_ready: bool = false
onready var goal: Goal = $Goal


func _ready():
	is_ready = true
	$Goal.connect("letter_inside_goal", self, "_on_letter_inside_goal")
	$LetterContainer.goal = $Goal


func intro():
	var cursor: float = 0.0
	for child in $LetterContainer.get_children():
		$Tween.interpolate_callback(child, cursor, "set_emit", true)
		cursor += rand_range(0.15, 0.4)
	$Tween.interpolate_callback($TitleContainer/Title, cursor, "dissolve")
	$Tween.interpolate_callback(AudioPlayer, cursor, "play_effect", TYPEWRITER_CARRIAGE_RETURN_AUDIO)
	$Tween.interpolate_callback(AudioPlayer, cursor + 1.0, "play_effect", TYPEWRITER_BELL_AUDIO)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	emit_signal("intro_completed")


func reset():
	$TitleContainer/Title.dissolve_progress = 0.0
	$Goal/OffscreenPointer.visible = false


func _on_letter_inside_goal(letter):
	for child in $LetterContainer.get_children():
		if child.state == Const.LetterSpriteState.NORMAL:
			return
	Events.emit_signal("level_completed", self)
	$LetterContainer.explode_letters()
