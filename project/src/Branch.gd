tool
class_name Branch
extends Node2D


signal leaf_added(parent_branch, leaf)
signal branch_added(parent_branch, branch)


export var aspect_ratio: float = 1.0 / 15.0

export var branch_length_avg: float = 200.0
export var branch_length_range: float = 20.0
export var branch_length_easing: float = 2.0
export var branch_length_attenuation: float = 0.95
var branch_length_random: float = 0.0

export var branch_angle_avg: float = 60.0
export var branch_angle_range: float = 20.0
export var branch_angle_easing: float = 2.0
export var branch_angle_attenuation: float = 1.05

export var branch_ratio_avg: float = 0.7
export var branch_ratio_range: float = 0.1
export var branch_ratio_easing: float = 2.0

export var leaf_length_avg: float = 0.7
export var leaf_length_range: float = 0.2
export var leaf_length_easing: float = 1.5
var leaf_length_random: float = 0.0

onready var leaves: Node2D = $Leaves
onready var branches: Node2D = $Branches
onready var line: Line2D = $Line2D

var branch_ratio: float = 1.0
var width_ratio: float = 1.0
var length: float = 0.0
var longest_length: float = 0.0
var is_ready: bool = false


func get_origin_width() -> float:
	return get_width_at_offset(0.0)


func get_tip_width() -> float:
	return get_width_at_offset(1.0)


func get_width_at_offset(offset: float) -> float:
	return line.width * line.width_curve.interpolate(offset)


func _ready() -> void:
	is_ready = true


func bind_leaf(leaf: Leaf):
	if not leaf.is_connected("water_received", self, "_on_leaf_water_received"):
		leaf.connect("water_received", self, "_on_leaf_water_received")
	if not leaf.is_connected("tree_exiting", self, "_on_leaf_tree_exiting"):
		leaf.connect("tree_exiting", self, "_on_leaf_tree_exiting", [leaf])


func unbind_leaf(leaf: Leaf):
	if leaf.is_connected("water_received", self, "_on_leaf_water_received"):
		leaf.disconnect("water_received", self, "_on_leaf_water_received")
	if leaf.is_connected("tree_exiting", self, "_on_leaf_tree_exiting"):
		leaf.disconnect("tree_exiting", self, "_on_leaf_tree_exiting")


func _on_leaf_tree_exiting(leaf: Leaf):
	unbind_leaf(leaf)


func add_leaf():
	var leaf: Leaf = Global.LEAF_SCENE.instance()
	leaf.position = line.get_point_position(1)
	leaf.rotation = Math.HALF_PI
	if Math.random_bool():
		leaf.transform = Math.flip_h(leaf.transform, true)
	leaves.add_child(leaf)
	bind_leaf(leaf)
	emit_signal("leaf_added", self, leaf)


func create_branch(_branch_ratio: float, _width_ratio: float):
	var branch = Global.BRANCH_SCENE.instance() # Branch
	branch.aspect_ratio = aspect_ratio
	branch.branch_ratio = _branch_ratio
	branch.width_ratio = _width_ratio
	branch.branch_length_avg = branch_length_avg * branch_length_attenuation
	branch.branch_length_range = branch_length_range * branch_length_attenuation
	branch.branch_length_easing = branch_length_easing
	branch.branch_angle_avg = branch_angle_avg * branch_angle_attenuation
	branch.branch_angle_range = branch_angle_range * branch_angle_attenuation
	branch.branch_angle_easing = branch_angle_easing
	branch.branch_ratio_avg = branch_ratio_avg
	branch.branch_ratio_range = branch_ratio_range
	branch.branch_ratio_easing = branch_ratio_easing
	return branch


func add_branches(branch_length: float):
	var ratio1: float = Math.random_weighted_range(branch_ratio_avg, branch_ratio_range, branch_ratio_easing)
	var ratio2: float = 1.0 - ratio1
	var width_ratio1: float = 1.0 if ratio1 > ratio2 else ratio1 / ratio2
	var width_ratio2: float = ratio2 / ratio1 if ratio1 > ratio2 else 1.0

	var angle_degrees: float = Math.random_weighted_range(branch_angle_avg, branch_angle_range, branch_angle_easing)

	var tip_position: Vector2 = line.get_point_position(1)

	var branch1 = create_branch(ratio1, width_ratio1)
	branch1.rotation_degrees = angle_degrees * ratio2
	branch1.position = tip_position
	branches.add_child(branch1)
#	branch1.grow(branch_length * width_ratio1)
	branch1.grow(branch_length * 0.5)

	emit_signal("branch_added", self, branch1)

	var branch2 = create_branch(ratio2, width_ratio2)
	branch2.rotation_degrees = angle_degrees * -ratio1
	branch2.position = tip_position
	branches.add_child(branch2)
#	branch2.grow(branch_length * width_ratio2)
	branch2.grow(branch_length * 0.5)

	emit_signal("branch_added", self, branch2)

	longest_length = length + max(branch1.longest_length, branch2.longest_length)


func grow(amount: float):
	var branch_count: int = branches.get_child_count()
	if branch_count > 0:
		var longest_branch_length: float = 0.0
		for branch in branches.get_children():
#			branch.grow(amount * branch.width_ratio)
			branch.grow(amount * (1.0 / float(branch_count)))
			longest_branch_length = max(longest_branch_length, branch.longest_length)
		longest_length = length + longest_branch_length

	else:
		if branch_length_random == 0.0:
			branch_length_random = Math.random_weighted_range(branch_length_avg, branch_length_range, branch_length_easing)
			leaf_length_random = branch_length_random * Math.random_weighted_range(leaf_length_avg, leaf_length_range, leaf_length_easing)

		var remainder_length: float = 0.0
		longest_length += amount
		if branch_length_random > 0.0 and longest_length > branch_length_random:
			remainder_length = longest_length - branch_length_random
			length = branch_length_random
		else:
			length = longest_length

		var tip_position: Vector2 = Vector2(length, 0.0)
		line.set_point_position(1, tip_position)

		if remainder_length > 0.0:
			add_branches(remainder_length)

		if length > leaf_length_random and leaves.get_child_count() <= 0:
			add_leaf()


	if branch_ratio == 1.0:
		line.width = max(longest_length * aspect_ratio, 2.0) if longest_length > 0.0 else 2.0


	for branch in branches.get_children():
		branch.line.width = branch.width_ratio * get_tip_width()

	for leaf in leaves.get_children():
		leaf.grow(amount)
