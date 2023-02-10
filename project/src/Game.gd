class_name Game
extends Node2D


const RECT_ZERO: Rect2 = Rect2()


export var camera_margin: float = 100.0

onready var drop_manager: DropManager = $"%DropManager"
onready var plant: Plant = $"%Plant"
onready var glass: Glass = $"%Glass"
onready var camera: Camera2D = $"%Camera2D"

var is_ready: bool = false
var elapsed_time: float = 0.0


func _ready():
	is_ready = true
	Global.game = self


func _process(delta: float) -> void:
	if not is_ready or plant.bbox == RECT_ZERO:
		return


	# =========================================================
	# Lightning
	# =========================================================

	elapsed_time += delta
	var lightning: float = sin(elapsed_time * sin(elapsed_time * 10.0)) # lighting flicker
	lightning *= pow(max(0.0, sin(elapsed_time + sin(elapsed_time))), 10.0) # lightning flash
	glass.set_lightning(lightning)
	plant.set_lightning(lightning)


	# =========================================================
	# Drops
	# =========================================================

#	var drop_uvs: Array = []
#	var screen_size: Vector2 = get_viewport_rect().size
#	for drop in drop_manager.drops.values():
#		var screen_position: Vector2 = drop.get_global_transform_with_canvas().origin
#		var uv: Vector2 = screen_position / screen_size
#		drop_uvs.append(uv)
#	glass.set_drops_texture(Img.create_vector_array_texture(drop_uvs))


	# =========================================================
	# Camera
	# =========================================================

	var plant_rect: Rect2 = plant.bbox
	plant_rect.position += plant.position
	plant_rect = plant_rect.grow_individual(camera_margin, camera_margin, camera_margin, 0.0)

	var viewport_rect: Rect2 = get_viewport_rect()
	if plant_rect.size.x > viewport_rect.size.x or plant_rect.size.y > viewport_rect.size.y:
		var target_scale: Vector2 = get_viewport_rect().size / plant_rect.size
		var max_scale: float = 1.0 / min(target_scale.x, target_scale.y)
		camera.zoom = Vector2(max_scale, max_scale)

	if not viewport_rect.encloses(plant_rect):
		var viewport_extents: Vector2 = viewport_rect.size * 0.5
		var camera_position: Vector2 = Vector2(plant.position.x, plant.position.y - viewport_extents.y)

		if plant_rect.end.x > viewport_rect.end.x:
			camera_position.x += 0.5 * (plant_rect.end.x - viewport_rect.end.x)
		if plant_rect.position.x < viewport_rect.position.x:
			camera_position.x -=  0.5 * (viewport_rect.position.x - plant_rect.position.x)

		if plant_rect.end.y > viewport_rect.end.y:
			camera_position.y +=  0.5 * (plant_rect.end.y - viewport_rect.end.y)
		if plant_rect.position.y < viewport_rect.position.y:
			camera_position.y -=  0.5 * (viewport_rect.position.y - plant_rect.position.y)

		camera.position = camera_position
