tool
class_name Branch
extends Node2D


#const BRANCH_SCENE: PackedScene = preload("res://src/Branch.tscn")
const LEAF_SCENE: PackedScene = preload("res://src/Leaf.tscn")

signal leaf_added(parent_branch, leaf)
signal branch_added(parent_branch, branch)


export var aspect_ratio = 1.0 / 15.0

onready var leaves: Node2D = $Leaves
onready var branches: Node2D = $Branches
onready var line: Line2D = $Line2D


var length: float setget set_length
var is_ready: bool = false


func set_length(value: float):
	length = value
	if is_ready:
		var point_position: Vector2 = Vector2(0.0, -length)
		line.set_point_position(1, point_position)
		line.width = max(length * aspect_ratio, 2.0) if length > 0.0 else 2.0


func _ready() -> void:
	is_ready = true
	set_length(length)


func add_leaf():
	var leaf: Leaf = LEAF_SCENE.instance()
	leaf.position = line.get_point_position(1)
	if Math.random_bool():
		leaf.transform = Math.flip_h(leaf.transform, true)
	leaves.add_child(leaf)
	emit_signal("leaf_added", self, leaf)
	return leaf


#func add_branch():
#	var branch: Branch = BRANCH_SCENE.instance()
#	branch.rotation = Math.random_turn_angle(Math.QUARTER_PI)
#	branch.position = line.get_point_position(1)
#	if Math.random_bool():
#		branch.transform = Math.flip_h(branch.transform, true)
#	branches.add_child(branch)
#	emit_signal("branch_added", self, branch)
#	return branch
