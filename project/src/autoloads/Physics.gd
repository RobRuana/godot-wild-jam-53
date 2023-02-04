extends Node


signal initialized

var is_initialized: bool = false
var layers: = {}
var layer_names: = {}


func _ready():
	for i in range(20):
		var layer = ProjectSettings.get_setting("layer_names/2d_physics/layer_" + str(i + 1))
		if layer:
			var layer_bitmask: int = int(pow(2, i))
			layers[layer] = layer_bitmask
			layer_names[layer_bitmask] = layer

	is_initialized = true
	emit_signal("initialized")


func get_collision_shape_rect(collision_shape: CollisionShape2D) -> Rect2:
	var extents: Vector2 = get_shape_extents(collision_shape.shape)
	return Rect2(collision_shape.position - extents, extents * 2.0)


func get_shape_extents(shape: Shape2D) -> Vector2:
	if shape is RectangleShape2D:
		var rectangle: RectangleShape2D = shape as RectangleShape2D
		return rectangle.extents
	elif shape is CapsuleShape2D:
		var capsule: CapsuleShape2D = shape as CapsuleShape2D
		return Vector2(capsule.radius, capsule.height)
	elif shape is CircleShape2D:
		var circle: CircleShape2D = shape as CircleShape2D
		return Vector2(circle.radius, circle.radius)
	elif shape is ConvexPolygonShape2D:
		var polygon: ConvexPolygonShape2D = shape as ConvexPolygonShape2D
		if polygon.points:
			var x_min: float = polygon.points[0].x
			var x_max: float = polygon.points[0].x
			var y_min: float = polygon.points[0].y
			var y_max: float = polygon.points[0].y
			for point in polygon.points:
				x_min = min(x_min, point.x)
				x_max = max(x_max, point.x)
				y_min = min(y_min, point.y)
				y_max = max(y_max, point.y)
			return Vector2(x_max - x_min, y_max - y_min) * 0.5
	return Vector2.ZERO
