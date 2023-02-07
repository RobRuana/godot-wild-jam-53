class_name Plant
extends Node2D


export(float, 0.0, 1.0) var crookedness: float = 0.0
export(float, 0.0, 1.0) var leafiness: float = 0.0
export(float, 0.0, 1.0) var branchiness: float = 0.0

export var initial_nutrients: float = 100.0


onready var trunk: Branch = $Trunk


var nutrients: float = 100.0
var moisture: float = 0.0
var growth_rate: float = 100.0
var evaporation_rate: float = 1.0
var is_ready: bool = false


func _ready() -> void:
	nutrients = initial_nutrients
	is_ready = true


func _physics_process(delta: float) -> void:
	if is_ready:
		moisture -= evaporation_rate * delta
		#trunk.grow(growth_rate * delta)


func add_moisture(value: float):
	pass
