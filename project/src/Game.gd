class_name Game
extends Node2D


onready var plant: Plant = $"%Plant"
onready var glass: Glass = $"%Glass"
onready var camera: Camera2D = $"%Camera2D"

var is_ready: bool = false


func _ready():
	is_ready = true
	Global.game = self


#func _process(delta: float) -> void:
#	if is_ready:
#		if not plant.bbox.has_no_area():
#			fit_rect(plant.bbox)
#
#
#func fit_rect(rect: Rect2):
#	var target_scale: Vector2 = get_viewport_rect().size / rect.size
#	var target_center: Vector2 = rect.get_center()
#
#	camera.position = target_center
#	camera.zoom = target_scale
