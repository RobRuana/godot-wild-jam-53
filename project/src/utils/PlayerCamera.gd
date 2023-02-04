class_name PlayerCamera
extends Camera2D


onready var noise: = OpenSimplexNoise.new()
var shake_noise_y: float = 0.0
export var shake_decay: float = 1.5  # How quickly the shaking stops
export var shake_offset_max: = Vector2(18.0, 18.0)  # Maximum hor/ver shake in pixels
var shake_decay_current: float = 1.5
var shake_decay_delay: float = 0.0
var shake_strength: float = 0.0  # Current shake strength
var shake_power: float = 2.0  # Shake exponent, use [2, 3]


func _ready() -> void:
	self.offset = Vector2.ZERO
	noise.seed = randi()
	noise.period = 4
	noise.octaves = 2
	Events.connect("camera_shake", self, "_on_camera_shake")


func _process(delta):
	if not is_zero_approx(shake_strength):
		if shake_decay_delay > 0.0:
			shake_decay_delay -= delta
		else:
			shake_strength = max(shake_strength - (shake_decay_current * delta), 0.0)
		_do_shake()

func _on_camera_shake(strength: float = 1.0, decay_delay: float = 0.2, decay: float = -1.0):
	shake(strength, decay_delay, decay)

func shake(strength: float = 1.0, decay_delay: float = 0.2, decay: float = -1):
	set_process(true)
	# https://kidscancode.org/godot_recipes/2d/screen_shake/
	shake_strength = min(shake_strength + strength, max(strength, 1.0))
	shake_decay_delay = decay_delay
	shake_decay_current = decay if decay > 0.0 else shake_decay
	_do_shake()

func _do_shake():
	var shake_amount: = pow(shake_strength * 2.0, shake_power)
	shake_noise_y += 1
	var zoom_factor: = 1.0 if zoom.x >= 1.0 or is_equal_approx(zoom.x, 1.0) else sqrt(zoom.x)
	offset.x = shake_offset_max.x * shake_amount * noise.get_noise_2d(noise.seed * 2.0, shake_noise_y) * zoom_factor
	offset.y = shake_offset_max.y * shake_amount * noise.get_noise_2d(noise.seed * 3.0, shake_noise_y) * zoom_factor
