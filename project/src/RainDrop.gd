class_name RainDrop
extends Node2D


onready var sprite: Sprite = $"%Sprite"

var is_ready: bool = false
var gravity: float = float(ProjectSettings.get_setting("physics/2d/default_gravity"))
var velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
	is_ready = true


func get_rect() -> Rect2:
	if is_ready:
		var size: Vector2 = Img.get_display_size(sprite)
		return Rect2(-0.5 * size, size)
	return Rect2(Vector2(-1.0, -1.0), Vector2(2.0, 2.0))


func get_center() -> Vector2:
	return Vector2.ZERO


func _physics_process(delta: float) -> void:
	var scale_factor: float = min(scale.x, scale.y)
	position.y += delta * (velocity.y + (gravity * delta * scale_factor * 0.5))
	velocity.y += gravity * delta * scale_factor
