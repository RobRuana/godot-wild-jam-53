tool
class_name Leaf
extends Node2D


signal water_received(leaf, amount)


export var leaf_aspect_ratio: float = 0.6
export var stem_ratio: float = 0.2
export var min_stem_length: float = 20.0
export var max_stem_length: float = -1.0

export var color_gradient: Gradient

export (float, 0.0, 1.0) var health: float = 1.0 setget set_health

onready var water_sensor: Area2D = $WaterSensor


func set_health(value: float):
	health = value
	modulate = color_gradient.interpolate(clamp(1.0 - value, 0.0, 1.0))


func _ready() -> void:
	set_health(health)
	water_sensor.connect("area_entered", self, "_on_water_sensor_entered")
	water_sensor.connect("body_entered", self, "_on_water_sensor_entered")


func _on_water_sensor_entered(body: Node2D):
	var water: float = 1.0
	if health < 1.0:
		var remainder: float = 1.0 - health
		water -= remainder
		health += remainder
	if water > 0.0:
		emit_signal("water_received", self, water)
