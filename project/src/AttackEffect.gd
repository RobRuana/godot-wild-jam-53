class_name AttackEffect
extends Node2D


export var autoplay: bool = true
export var autoremove: bool = true
export var duration: float = 0.3
export var emit: bool = false setget set_emit
export var radius: float = 160.0 setget set_radius
export (float, 0.0, 1.0) var progress: float = 0.0 setget set_progress


func set_emit(value: bool):
	if value:
		play()
	else:
		stop()


func set_radius(value: float):
	radius = value
	if has_node("TextureRect"):
		var width: float = 2.0 * radius
		$TextureRect.rect_min_size = Vector2(width, width)
		$TextureRect.rect_size = Vector2(width, width)
		$TextureRect.rect_position = Vector2(-radius, -radius)


func set_progress(value: float):
	progress = value
	if has_node("TextureRect"):
		$TextureRect.material.set_shader_param("progress", value)


func _ready():
	if autoplay:
		play()


func play():
	emit = true
	$Tween.interpolate_property(self, "progress", 0.0, 1.0, duration, Tween.TRANS_SINE, Tween.EASE_OUT)
	$Tween.start()
	yield($Tween, "tween_all_completed")
	emit = false
	if autoremove and not Engine.editor_hint:
		queue_free()


func stop():
	$Tween.remove_all()
	self.progress = 0.0
	emit = false
