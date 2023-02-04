class_name Plant
extends Node2D


export(float, 0.0, 1.0) var crookedness: float = 0.0
export(float, 0.0, 1.0) var leafiness: float = 0.0
export(float, 0.0, 1.0) var branchiness: float = 0.0

export var initial_nutrients: float = 100.0


onready var trunk: Branch = $Trunk


var nutrients: float = 100.0
var moisture: float = 0.0
var evaporation_rate: float = 1.0


func _ready() -> void:
	var tween: SceneTreeTween = trunk.create_tween().set_parallel(true)
	tween.tween_property(trunk, "length", 540.0, 10.0)
	nutrients = initial_nutrients


func _physics_process(delta: float) -> void:
	moisture -= evaporation_rate * delta


func add_moisture(value: float):
	pass
