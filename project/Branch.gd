tool
class_name Branch
extends Node2D


const LEAF: PackedScene = preload("res://Leaf.tscn")


export(float, 0.0, 1.0) var crookedness: float = 0.0
export(float, 0.0, 1.0) var leafiness: float = 0.0
export(float, 0.0, 1.0) var branchiness: float = 0.0

onready var leaves: Node2D = $Leaves
onready var line: Line2D = $Line2D


var length: float setget set_length
var is_ready: bool = false


func set_length(value: float):
	var old_value: float = length
	length = value
	if is_ready:
		var point_position: Vector2 = Vector2(0.0, -length)
		line.set_point_position(1, point_position)
		if length > 0:
			line.width = max(length / 15.0, 8.0)
		else:
			line.width = 8.0

		if old_value < 240.0 and value >= 240.0:
			var leaf: Leaf = LEAF.instance()
			leaf.scale = Vector2(0.1, 0.1)
			leaves.add_child(leaf)
			var tween: SceneTreeTween = leaf.create_tween().set_parallel(true)
			tween.tween_property(leaf, "scale", Vector2(1.0, 1.0), 5.0)
			leaf.rotate(Math.HALF_PI)
			leaf.position = point_position


func _ready() -> void:
	is_ready = true
	set_length(length)


#func _physics_process(delta: float) -> void:
#	pass
