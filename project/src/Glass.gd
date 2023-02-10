tool
class_name Glass
extends Control


onready var glass_shader: GlassShader = $"%GlassShader"
onready var rain_drops: RainDrops = $"%RainDrops"


var is_ready: bool = false


func _ready() -> void:
	is_ready = true


func set_lightning(value: float):
	if is_ready:
		glass_shader.set_lightning(value)
