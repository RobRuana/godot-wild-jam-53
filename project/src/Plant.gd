class_name Plant
extends Node2D


onready var trunk: Branch = $Trunk


var moisture: float = 0.0
var evaporation_rate: float = 1.0


func _ready() -> void:
	var tween: SceneTreeTween = trunk.create_tween().set_parallel(true)
	tween.tween_property(trunk, "length", 540.0, 10.0)


func _physics_process(delta: float) -> void:
	moisture -= evaporation_rate * delta


func add_moisture(value: float):
	pass
