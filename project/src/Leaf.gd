tool
class_name Leaf
extends Node2D


signal water_received(leaf, amount)


export var leaf_aspect_ratio: float = 0.6
export var stem_ratio: float = 0.2
export var max_length: float = 100.0
export var color_gradient: Gradient

export (float, 0.0, 1.0) var health: float = 1.0 setget set_health

onready var collision_shape: CollisionShape2D = $"%CollisionShape2D"
onready var line: Line2D = $"%Line2D"
onready var polygon: Polygon2D = $"%Polygon2D"
onready var water_sensor: Area2D = $"%WaterSensor"


func set_health(value: float):
	health = value
	modulate = color_gradient.interpolate(clamp(1.0 - value, 0.0, 1.0))


func _ready() -> void:
	var stem_length: float = max_length * stem_ratio
	var leaf_length: float = max_length - stem_length
	var leaf_extent: float = leaf_length * 0.5
	line.set_point_position(1, Vector2(max_length, 0.0))
	var points: PoolVector2Array = Math.make_circle_polygon(leaf_extent, Vector2.ZERO, 32)
	points = Transform2D.IDENTITY.scaled(Vector2(1.0, leaf_aspect_ratio)).xform(points)

	if collision_shape.shape == null:
		collision_shape.shape = ConvexPolygonShape2D.new()
		collision_shape.shape.set_point_cloud(points)
		collision_shape.disabled = false
		collision_shape.position = Vector2(stem_length + leaf_extent, 0.0)

	polygon.polygon = points
	polygon.position = Vector2(stem_length + leaf_extent, 0.0)

	set_health(health)

	scale = Vector2(0.1, 0.1)

	if not water_sensor.is_connected("area_entered", self, "_on_water_sensor_entered"):
		water_sensor.connect("area_entered", self, "_on_water_sensor_entered")
	if not water_sensor.is_connected("body_entered", self, "_on_water_sensor_entered"):
		water_sensor.connect("body_entered", self, "_on_water_sensor_entered")
	if not water_sensor.is_connected("input_event", self, "_on_water_sensor_input_event"):
		water_sensor.connect("input_event", self, "_on_water_sensor_input_event")


func _on_water_sensor_entered(body: Node2D):
	add_water(1.0)


func _on_water_sensor_input_event(viewport: Node, input_event: InputEvent, shape_idx: int):
	if (input_event is InputEventMouseButton && input_event.pressed):
		add_water(1.0)


func add_water(water: float):
	print("water_received: ", water)
	if health < 1.0:
		var remainder: float = 1.0 - health
		water -= remainder
		health += remainder
	if water > 0.0:
		emit_signal("water_received", self, water)


func grow(amount: float):
	var percent: float = amount / max_length
	var new_scale: Vector2 = scale * (1.0 + percent)
	scale = Vector2(min(new_scale.x, 1.0), min(new_scale.y, 1.0))
