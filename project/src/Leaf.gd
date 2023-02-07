tool
class_name Leaf
extends Node2D


signal water_received(leaf, amount)


export var lobe_aspect_ratio: float = 0.6
export var stem_length_ratio: float = 0.2
export var mature_length: float = 100.0
export var color_gradient: Gradient

export (float, 0.0, 1.0) var health: float = 1.0 setget set_health

onready var branch_offset: Node2D = $"%BranchOffset"
onready var lobes: Node2D = $"%Lobes"
onready var collision_shape: CollisionShape2D = $"%CollisionShape2D"
onready var stem: Line2D = $"%Stem"
onready var polygon: Polygon2D = $"%Polygon2D"
onready var water_sensor: Area2D = $"%WaterSensor"


var is_mature: bool = false
var is_ready: bool = false
var mature_stem_length: float
var mature_lobe_size: Vector2
var current_length: float = 0.0
var branch_width: float = 2.0 setget set_branch_width
var parent_segment_index: int = 0
var bbox: Rect2


func set_origin_color(color: Color):
	stem.gradient.set_color(0, color)


func set_tip_color(color: Color):
	stem.gradient.set_color(1, color)


func get_origin_color() -> Color:
	return get_color_at_offset(0.0)


func get_tip_color() -> Color:
	return get_color_at_offset(1.0)


func get_color_at_offset(offset: float) -> Color:
	return stem.gradient.interpolate(offset)


func set_branch_width(value: float):
	branch_width = value
	if is_ready:
		branch_offset.position.x = (branch_width * 0.5) - 2.0


func set_health(value: float):
	health = value
	lobes.modulate = color_gradient.interpolate(clamp(1.0 - value, 0.0, 1.0))


func _ready() -> void:
	mature_stem_length = mature_length * stem_length_ratio
	var mature_lobe_length: float = mature_length - mature_stem_length
	mature_lobe_size = Vector2(mature_lobe_length, mature_lobe_length * lobe_aspect_ratio)
	stem.set_point_position(1, Vector2(mature_length, 0.0))
	var points: PoolVector2Array = Math.make_leaf_polygon(mature_lobe_length, Vector2.ZERO, 24)
	points = Transform2D.IDENTITY.scaled(Vector2(1.0, lobe_aspect_ratio)).xform(points)

	var points_bbox: Rect2 = Math.bbox(points)

	if not collision_shape.shape is ConvexPolygonShape2D:
		collision_shape.shape = ConvexPolygonShape2D.new()
	collision_shape.shape.set_point_cloud(points)
	collision_shape.disabled = false
	collision_shape.position = Vector2(mature_stem_length + (mature_lobe_length * 0.5) - points_bbox.get_center().x, 0.0)

	polygon.polygon = points
	polygon.position = collision_shape.position

	is_ready = true

	set_branch_width(branch_width)
	set_health(health)

	if Engine.editor_hint:
		stem.set_point_position(1, Vector2(mature_length, 0.0))
		current_length = mature_length
		lobes.scale = Vector2(1.0, 1.0)
		lobes.visible = true
	else:
		stem.set_point_position(1, Vector2(0.0, 0.0))
		current_length = 0.0
		lobes.scale = Vector2(1.0, 0.0)
		lobes.visible = false

	if not water_sensor.is_connected("area_entered", self, "_on_water_sensor_entered"):
		water_sensor.connect("area_entered", self, "_on_water_sensor_entered")
	if not water_sensor.is_connected("body_entered", self, "_on_water_sensor_entered"):
		water_sensor.connect("body_entered", self, "_on_water_sensor_entered")
	if not water_sensor.is_connected("input_event", self, "_on_water_sensor_input_event"):
		water_sensor.connect("input_event", self, "_on_water_sensor_input_event")


func _on_water_sensor_entered(body: Node2D):
	add_water(1.0)


func _on_water_sensor_input_event(viewport: Node, input_event: InputEvent, shape_idx: int):
	if (input_event is InputEventMouseButton and input_event.pressed):
		add_water(1.0)


func add_water(water: float):
	print("water_received: ", water)
	if health < 1.0:
		var remainder: float = 1.0 - health
		water -= remainder
		health += remainder
	if water > 0.0:
		emit_signal("water_received", self, water)


func grow(amount: float) -> Rect2:
	var new_length: float = current_length + amount
	if new_length > mature_length:
		lobes.visible = true
		var remainder: float = new_length - mature_length
		new_length = mature_length
		if remainder > 0.0:
			var percent: float = remainder / mature_length
			var y_scale: float = min(lobes.scale.y + percent, 1.0)
			is_mature = (y_scale == 1.0)
			lobes.scale = Vector2(lobes.scale.x, y_scale)
	current_length = new_length
	stem.set_point_position(1, Vector2(current_length, 0.0))
	var current_size: Vector2 = Vector2(current_length, lobes.scale.y * mature_lobe_size.y)
	bbox = Rect2(Vector2(branch_offset.position.x, -0.5 * current_size.y), current_size)
	return bbox
