class_name Player
extends KinematicBody2D


const ATTACK_EFFECT: PackedScene = preload("res://src/AttackEffect.tscn")
const ATTACK_AUDIO: AudioStream = preload("res://assets/audio/cat_meow_01.wav")
const SCREAM_AUDIO: AudioStream = preload("res://assets/audio/cat_scream_01.wav")
const HURT_AUDIO: AudioStream = preload("res://assets/audio/punch_hard_01.wav")


export var color: Color = Color.black setget set_color
export var health: int = 3 setget set_health
export var invincibility_duration: float = 1.0
var invincibility_countdown: float = 0.0

export var attack_duration: float = 0.3

export var speed: = 450.0
export var acceleration: = 12.0
export var deceleration: = 6.0
export var rotation_speed: = 30.0
export var zoom_multiplier: = 2.0
export var zoom_duration: = 2.0
export var zoom_countdown: = 0.0 setget set_zoom_countdown
export var is_zoom_recovery: bool = false setget set_is_zoom_recovery
export var is_zoom: bool = true setget set_is_zoom

export var min_walk_speed: = 5.0


onready var anim_player: AnimationPlayer = $AnimationPlayer
onready var anim_tree: AnimationTree = $AnimationTree
onready var anim_state: AnimationNodeStateMachinePlayback = anim_tree.get("parameters/playback")
onready var torso: Trail2D = $Head/TorsoPosition/Torso
onready var tail: Trail2D = $Butt/TailPosition/Tail
onready var static_torso: Trail2D = $StaticTorsoPosition/StaticTorso
onready var zoom_trail: Trail2D = $ZoomTrailPosition/ZoomTrail

export var follow_target_path: NodePath setget set_follow_target_path
var follow_target: Node2D
var velocity: = Vector2.ZERO


func set_color(value: Color):
	color = value
	$Butt/Sprite.modulate = color
	$Butt/TailPosition/Tail.modulate = color
	$Paws.modulate = color
	$Head/Sprite.modulate = color
	$Head/TorsoPosition/Torso.modulate = color


func set_health(value: int):
	var old_value: int = health
	health = int(max(value, 0))
	Events.emit_signal("player_health_changed", self, value, old_value)
	if old_value > 0 and health == 0:
		Events.emit_signal("player_death", self)


func set_zoom_countdown(value: float):
	var old_value: float = zoom_countdown
	zoom_countdown = value
	if is_equal_approx(zoom_countdown, zoom_duration):
		self.is_zoom_recovery = false
	elif is_zero_approx(zoom_countdown):
		self.is_zoom_recovery = true
	if old_value != value:
		Events.emit_signal("player_zoom_changed", self, 100.0 * value / zoom_duration, 100.0 * old_value / zoom_duration)


func set_is_zoom_recovery(value: bool):
	var old_value: bool = is_zoom_recovery
	is_zoom_recovery = value
	if old_value != value:
		Events.emit_signal("player_zoom_recovery", self, value)


func set_is_zoom(value: bool):
	var old_value: bool = is_zoom
	is_zoom = value
	if old_value != value:
		Events.emit_signal("player_zoom", self, value)
		if is_zoom:
			zoom_trail.trail_length = 40
			$Fader.fade_to_opaque(zoom_trail)
		else:
			zoom_trail.trail_length = 0
			$Fader.fade_to_transparent(zoom_trail)


func is_disabled() -> bool:
	return health <= 0 or Global.game.state != Const.GameState.PLAYING


func set_follow_target_path(value: NodePath):
	follow_target_path = value
	if is_inside_tree():
		var scene = get_tree().current_scene
		if scene.has_node(follow_target_path):
			follow_target = scene.get_node(follow_target_path)
		else:
			follow_target = null


func _ready():
	self.zoom_countdown = zoom_duration
	Global.player = self
	$HitBox.connect("body_entered", self, "_on_hit_box_body_entered")
	$HurtBox.connect("body_entered", self, "_on_hurt_box_body_entered")


func _physics_process(delta: float):
	if invincibility_countdown > 0.0:
		invincibility_countdown -= delta
		if invincibility_countdown <= 0.0:
			invincibility_countdown = 0.0
			$HurtBox.reset()

	if follow_target:
		velocity = Vector2.ZERO
		global_position = follow_target.global_position
	else:
		_process_player_input(delta)

	var blend_walk: = min(velocity.length() / speed, 1.0)
	anim_parameter("walk/blend_walk/blend_amount", blend_walk)
	anim_condition("walk", is_disabled() or not is_zoom)
	anim_condition("zoom", not is_disabled() and is_zoom)

	if torso.points:
		$Paws.global_position = torso.points[-min(2, torso.points.size() - 1)]
		$Butt.global_position = torso.points[min(1, torso.points.size() - 1)]
	else:
		$Paws.global_position = global_position
		$Butt.global_position = global_position

	if static_torso.points:
		$ZoomTrailPosition.global_position = static_torso.points[0]
	else:
		$ZoomTrailPosition.global_position = global_position


func _process_player_input(delta: float):
	var wish_velocity: Vector2 = Vector2.ZERO

	if not is_disabled():
		var move: = InputCircular.get_action_strength("move")
		var multiplier: float = 1.0
		if not Math.is_zero_approx_v(move) and Input.is_action_pressed("zoom") and not is_zoom_recovery:
			self.zoom_countdown = max(zoom_countdown - delta, 0.0)
			if zoom_countdown > 0.0:
				self.is_zoom = true
				multiplier = zoom_multiplier
			else:
				self.is_zoom = false
		else:
			self.is_zoom = false
			self.zoom_countdown = min(zoom_countdown + delta, zoom_duration)

		# Move towards player direction (takes time to turn around based on rotation_speed)
#		var wish_speed: float = speed * move.length() * multiplier
#		wish_velocity = Vector2.UP.rotated(rotation) * wish_speed

		# Move towards input direction (turn around instantaneously)
		wish_velocity = speed * move * multiplier

	var wish_magnitude: = abs(wish_velocity.length_squared())
	var magnitude: = abs(velocity.length_squared())
	var delta_acceleration: float = deceleration if wish_magnitude < magnitude else acceleration
	velocity = move_and_slide(lerp(velocity, wish_velocity, delta * delta_acceleration))


func _unhandled_input(event):
	if is_disabled():
		return

	if event.is_action_pressed("attack"):
		attack()


func attack():
	if not $HitBox.monitoring:
		$HitBox.monitorable = true
		$HitBox.monitoring = true
		var attack_effect: AttackEffect = ATTACK_EFFECT.instance()
		attack_effect.radius = $HitBox/CollisionShape2D.shape.radius
		attack_effect.rotation = rand_range(0, Math.TWO_PI)
		attack_effect.duration = attack_duration
		attack_effect.z_index = -2
		add_child(attack_effect)
		move_child(attack_effect, 0)
#		var pitch_scale: = RandomAudioStreamPlayer.choose_pitch_scale(1.0, -0.1, 0.1)
#		AudioPlayer.play_effect(ATTACK_AUDIO, 1.0, pitch_scale)
		AudioPlayer.play_autotune_effect(ATTACK_AUDIO, 1.0)
		yield(get_tree().create_timer(attack_duration), "timeout")
		$HitBox.monitorable = false
		$HitBox.monitoring = false


func reset():
	self.health = 3
	self.zoom_countdown = zoom_duration
	self.color = Color.black


func teleport(point: Vector2):
	global_position = point
	torso.disabled = true
	torso.clear_points()
	tail.disabled = true
	tail.clear_points()
	zoom_trail.disabled = true
	zoom_trail.clear_points()


func anim_parameter(name: String, value):
	anim_tree.set("parameters/" + name, value)


func anim_condition(name: String, value: bool) -> void:
#	if anim_tree.get("parameters/conditions/" + name) != null:
#		if bool(not not anim_tree.get("parameters/conditions/" + name)) != value:
#			print("anim_condition: ", self.name, ".", name, " = ", value)

	anim_tree.set("parameters/conditions/" + name, value)
	anim_tree.set("parameters/conditions/not_" + name, not value)


func _on_hit_box_body_entered(body: Node2D):
	if is_disabled():
		return

	if body is LetterSprite:
		body.flee(global_position)


func _on_hurt_box_body_entered(body: Node2D):
	if is_disabled():
		return

	if body is LetterSprite and body.state == Const.LetterSpriteState.AGGRO and not invincibility_countdown:
		Events.emit_signal("camera_shake")
		self.health -= 1
		invincibility_countdown = invincibility_duration
		velocity = move_and_slide((global_position - body.global_position).normalized() * speed * 3.0)
		blink(invincibility_duration)
		AudioPlayer.play_effect(HURT_AUDIO)
		AudioPlayer.play_effect(SCREAM_AUDIO, 1.0, RandomAudioStreamPlayer.choose_pitch_scale(1.0, -0.1, 0.1), 0.2)


func blink(duration: float):
	$Tween.remove_all()
	var interval: float = 0.05
	var cursor: float = 0.0
	var colors: = [Color.white, Color.black]
	var color_index: = 0
	while cursor < duration:
		$Tween.interpolate_callback(self, cursor, "set_color", colors[color_index])
		color_index = (color_index + 1) % colors.size()
		cursor += interval
	$Tween.interpolate_callback(self, duration, "set_color", Color.black)
	$Tween.start()

