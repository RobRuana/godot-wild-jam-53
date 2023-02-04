tool
class_name Leaf
extends Node2D


signal water_added()


export var color_gradient: Gradient

export (float, 0.0, 1.0) var health: float = 1.0 setget set_health


onready var moisture_sensor: Area2D = $MoistureSensor


func set_health(value: float):
	health = value
	modulate = color_gradient.interpolate(clamp(1.0 - value, 0.0, 1.0))


func _ready() -> void:
	set_health(health)
	moisture_sensor.connect("area_entered", self, "_on_moisture_sensor_entered")
	moisture_sensor.connect("body_entered", self, "_on_moisture_sensor_entered")


func _on_moisture_sensor_entered(body: Node2D):
	emit_signal("water_added")
