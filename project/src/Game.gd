class_name Game
extends Node2D


onready var plant: Plant = $Plant
onready var glass: Glass = $Glass


func _ready():
	Global.game = self


func _process(delta: float) -> void:
	pass


func _physics_process(delta: float) -> void:
	pass
