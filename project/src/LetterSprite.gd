class_name LetterSprite
extends KinematicBody2D


const AGGRO_AUDIO: AudioStream = preload("res://assets/audio/letter_aggro_01.wav")
const INSIDE_GOAL_AUDIO: AudioStream = preload("res://assets/audio/letter_inside_goal_01.wav")
const EMIT_AUDIO: AudioStream = preload("res://assets/audio/typewriter_return_01.wav")
const BACKSPACE_AUDIO: AudioStream = preload("res://assets/audio/typewriter_backspace_01.wav")

export var letter: String = "" setget set_letter
export var state: int = 0 setget set_state
export var emit: bool = false setget set_emit
export var backspace: bool = false setget set_backspace

export var speed: = 100.0
export var aggro_speed: = 300.0
export var flee_speed: = 1000.0

export var min_walk_speed: = 5.0

export var character_index: int = 0

var destination: = Vector2.ZERO
var destination_box: Rect2
var rect: Rect2
var radius: float

var goal
var goal_duration: float = 0.0
export var goal_aggro_timeout: float = 10.0

var velocity: = Vector2.ZERO
export var acceleration: = 12.0
export var deceleration: = 6.0

onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var anim_tree: AnimationTree = $AnimationTree
onready var anim_state: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")
onready var sprite: Sprite = $Sprite


func set_state(value: int):
	state = value
	if not Engine.editor_hint:
		if state == Const.LetterSpriteState.INSIDE_GOAL:
			destination = goal.global_position if goal else global_position
			flash()
			AudioPlayer.play_effect(INSIDE_GOAL_AUDIO, 1.0, RandomAudioStreamPlayer.choose_pitch_scale(1.0, -0.05, 0.05))
		elif state == Const.LetterSpriteState.AGGRO:
			$Tween.interpolate_property($Sprite.material, "shader_param/strength", 0.0, 1.0, 0.5, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			$Tween.interpolate_property(self, "modulate", null, Color.red, 0.5, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
			$Tween.start()
			AudioPlayer.play_effect(AGGRO_AUDIO, 1.0, RandomAudioStreamPlayer.choose_pitch_scale(1.0, -0.05, 0.05))


func set_emit(value: bool):
	if Engine.editor_hint:
		return

	if value:
		visible = true
		if AudioPlayer.has_method("play_effect"):
			var pitch: float = RandomAudioStreamPlayer.choose_pitch_scale(1.0, -0.05, 0.05)
			AudioPlayer.play_effect(EMIT_AUDIO, 1.0, pitch)


func set_backspace(value: bool):
	if Engine.editor_hint:
		return

	if value:
		visible = false
		if AudioPlayer.has_method("play_effect"):
			var pitch: float = RandomAudioStreamPlayer.choose_pitch_scale(1.0, -0.05, 0.05)
			AudioPlayer.play_effect(BACKSPACE_AUDIO, 1.0, pitch)


func set_letter(value: String):
	letter = value.replace(" ", "_").strip_edges()
	if not letter.empty():
		if has_node("Sprite"):
			$Sprite.texture = Letters.get_letter_texture(letter)

		if has_node("CollisionShape2D"):
			rect = Letters.get_letter_rect(letter)
			radius = max(rect.size.x, rect.size.y) * 0.5
			var shape: = CapsuleShape2D.new()
			var min_dimension: = min(rect.size.x, rect.size.y)
			shape.radius = min_dimension * 0.5
			if rect.size.y > rect.size.x:
				shape.height = max(rect.size.y - min_dimension, 0.0)
			else:
				shape.height = max(rect.size.x - min_dimension, 0.0)
				$CollisionShape2D.rotation_degrees = 90.0
			$CollisionShape2D.shape = shape
			$CollisionShape2D.position = rect.position + (rect.size * 0.5) - ($Sprite.texture.get_size() * 0.5)
			rect.position = $CollisionShape2D.position - (rect.size * 0.5)
			destination_box = Rect2(rect.position + rect.size * 0.25, rect.size * 0.5)


func global_destination_box():
	return Rect2(to_global(destination_box.position), destination_box.size)


func _ready():
	destination = global_position
	anim_parameter("walk/time_scale/scale", rand_range(0.95, 1.05))


func _physics_process(delta: float):
	if Engine.editor_hint or Global.game.state != Const.GameState.PLAYING:
		return

	var width: = max(rect.size.x, rect.size.y)
	var box: Rect2 = global_destination_box()
	if state == Const.LetterSpriteState.INSIDE_GOAL:
		goal_duration += delta
		if goal_duration >= goal_aggro_timeout:
			self.state = Const.LetterSpriteState.AGGRO
	elif state == Const.LetterSpriteState.NORMAL:
		if box.has_point(destination):
			destination += random_offset(width, width + 300.0)

	var move_speed: = speed
	if state == Const.LetterSpriteState.AGGRO:
		move_speed = aggro_speed
		destination = Global.player.global_position + random_offset(0.0, 100.0)

	var move: Vector2 = (destination - global_position).normalized()
	var wish_velocity: Vector2 = move_speed * move

	var wish_magnitude: = abs(wish_velocity.length_squared())
	var magnitude: = abs(velocity.length_squared())
	var delta_acceleration: float = deceleration if wish_magnitude < magnitude else acceleration
	velocity = move_and_slide(lerp(velocity, wish_velocity, delta * delta_acceleration))

	var blend_walk: = min(velocity.length() / speed, 1.0)
	anim_parameter("walk/blend_walk/blend_amount", blend_walk)


func anim_parameter(name: String, value):
	anim_tree.set("parameters/" + name, value)


func anim_condition(name: String, value: bool) -> void:
#	if anim_tree.get("parameters/conditions/" + name) != null:
#		if bool(not not anim_tree.get("parameters/conditions/" + name)) != value:
#			print("anim_condition: ", self.name, ".", name, " = ", value)

	anim_tree.set("parameters/conditions/" + name, value)
	anim_tree.set("parameters/conditions/not_" + name, not value)


func random_offset(lower: float = 0.0, upper: float = 100.0) -> Vector2:
	 return Vector2(
		(-1.0 if randf() < 0.5 else 1.0) * rand_range(lower, upper),
		(-1.0 if randf() < 0.5 else 1.0) * rand_range(lower, upper)
	)


func flee(point: Vector2):
	if state != Const.LetterSpriteState.NORMAL:
		return

	var move: Vector2 = (global_position - point).normalized()
	var wish_velocity: Vector2 = flee_speed * move * (4.0 if Global.game.state == Const.GameState.INTRO else 1.0)
	velocity = move_and_slide(wish_velocity)


func flash():
	var old_modulate: = modulate
	modulate = Color.white
	$Tween.interpolate_property(self, "modulate", null, old_modulate, 1.0, Tween.TRANS_SINE, Tween.EASE_IN_OUT, 0.2)
	$Tween.start()
