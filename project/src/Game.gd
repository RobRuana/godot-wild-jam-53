class_name Game
extends Control


export var camera_margin: float = 100.0


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
#			var plant_bbox: Rect2 = plant.bbox
#			plant_bbox.position += plant.position
#			plant_bbox.grow(camera_margin)
#			zoom_camera_to_rect(plant_bbox)


func zoom_camera_to_rect(rect: Rect2):
	var viewport_rect: Rect2 = get_viewport_rect()
	var viewport_size: Vector2 = viewport_rect.size
	if rect.size.x > viewport_size.x or rect.size.y > viewport_size.y:
		var target_scale: Vector2 = get_viewport_rect().size / rect.size
#		var max_scale: float = 1.0 / min(target_scale.x, target_scale.y)
#		camera.zoom = Vector2(max_scale, max_scale)

		var max_scale: float = min(target_scale.x, target_scale.y)
		plant.scale = Vector2(max_scale, max_scale)

#	if not viewport_rect.encloses(rect):
#		var viewport_center: Vector2 = viewport_rect.get_center()
#		var camera_position: Vector2 = viewport_center
#
#		if rect.end.x > viewport_rect.end.x:
#			camera_position.x += 0.5 * (rect.end.x - viewport_rect.end.x)
#		if rect.position.x < viewport_rect.position.x:
#			camera_position.x -= 0.5 * (viewport_rect.position.x - rect.position.x)
#
#		if rect.end.y > viewport_rect.end.y:
#			camera_position.y += 0.5 * (rect.end.y - viewport_rect.end.y)
#		if rect.position.y < viewport_rect.position.y:
#			camera_position.y -= 0.5 * (viewport_rect.position.y - rect.position.y)
#
#		camera.position = camera_position
