tool
class_name Branch
extends Node2D


signal leaf_added(parent_branch, leaf)
signal branch_added(parent_branch, branch)


export var aspect_ratio: float = 1.0 / 15.0
export var min_width: float = 2.0

export(float, 0.0, 1.0) var branchiness: float = 0.2
export(float, 0.0, 1.0) var leafiness: float = 0.4


export var segment_length_avg: float = 100.0
export var segment_length_range: float = 20.0
export var segment_length_easing: float = 2.0
export var segment_length_attenuation: float = 0.95

export var segment_angle_avg: float = 15.0
export var segment_angle_range: float = 5.0
export var segment_angle_easing: float = 2.0
export var segment_angle_attenuation: float = 1.05


onready var leaves: Node2D = $Leaves
onready var branches: Node2D = $Branches
onready var line: Line2D = $Line2D


var current_segment_index: int = 0
var current_segment_length: float = 0.0
var current_segment_direction: Vector2 = Vector2.UP
var current_segment_length_target: float = 0.0

var length: float = 0.0
var is_ready: bool = false


func get_origin_width() -> float:
	return get_width_at_offset(0.0)


func get_tip_width() -> float:
	return get_width_at_offset(1.0)


func get_width_at_offset(offset: float) -> float:
	return line.width * line.width_curve.interpolate(offset)


func _ready() -> void:
	while line.get_point_count() < 2:
		line.add_point(Vector2.ZERO)
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


func bind_branch(branch): # Branch
	if not branch.is_connected("tree_exiting", self, "_on_branch_tree_exiting"):
		branch.connect("tree_exiting", self, "_on_branch_tree_exiting", [branch])


func unbind_branch(branch): # Branch
	if branch.is_connected("tree_exiting", self, "_on_branch_tree_exiting"):
		branch.disconnect("tree_exiting", self, "_on_branch_tree_exiting")


func _on_leaf_water_received(leaf: Leaf, amount: float):
	pass


func _on_leaf_tree_exiting(leaf: Leaf):
	unbind_leaf(leaf)


func _on_branch_tree_exiting(branch): # Branch
	unbind_branch(branch)


func create_branch():
	var branch = Global.BRANCH_SCENE.instance() # Branch
	branch.aspect_ratio = aspect_ratio
	branch.min_width = min_width
	branch.branchiness = branchiness
	branch.leafiness = leafiness
	branch.segment_length_avg = segment_length_avg * segment_length_attenuation
	branch.segment_length_range = segment_length_range * segment_length_attenuation
	branch.segment_length_easing = segment_length_easing
	branch.segment_length_attenuation = segment_length_attenuation
	branch.segment_angle_avg = segment_angle_avg * segment_angle_attenuation
	branch.segment_angle_range = segment_angle_range * segment_angle_attenuation
	branch.segment_angle_easing = segment_angle_easing
	branch.segment_angle_attenuation = segment_angle_attenuation
	return branch


func create_leaf():
	var leaf: Leaf = Global.LEAF_SCENE.instance()
	return leaf


func get_outside_bisection(segment_index: int, weight: float = 0.5):
	var p1: Vector2 = line.get_point_position(segment_index - 1)
	var p2: Vector2 = line.get_point_position(segment_index)
	var p3: Vector2 = line.get_point_position(segment_index + 1)
	var s1: Vector2 = p2 - p1
	var s2: Vector2 = p3 - p2
	var outside_angle: float = Math.get_obtuse_angle(s1, s2)
	var s1_angle: float = s1.angle()
	return s1_angle + (outside_angle * weight)


func add_leaf(segment_index: int):
	var leaf: Leaf = create_leaf()
	leaf.position = line.get_point_position(segment_index)
	leaf.rotation = get_outside_bisection(segment_index, 0.5)
	leaves.add_child(leaf)
	bind_leaf(leaf)
	emit_signal("leaf_added", self, leaf)


func add_branch(segment_index: int):
	var branch = create_branch()
	branch.position = line.get_point_position(segment_index)
	branches.add_child(branch)
	bind_branch(branch)
	emit_signal("branch_added", self, branch)


func grow(amount: float):
	if !is_ready:
		return

	if current_segment_length_target <= 0.0:
		current_segment_length_target = Math.random_weighted_range(segment_length_avg, segment_length_range, segment_length_easing)

#	var branch_amount: float = amount / float(branches.get_child_count() + leaves.get_child_count() + 1.0)
	var branch_amount: float = amount

	for branch in branches.get_children():
		branch.grow(branch_amount)

	for leaf in leaves.get_children():
		leaf.grow(branch_amount)

	var is_new_segment: bool = false
	var new_segment_length: float = current_segment_length + branch_amount
	if new_segment_length > current_segment_length_target:
		branch_amount = new_segment_length - current_segment_length_target
		new_segment_length = branch_amount

		var origin: Vector2 = line.get_point_position(current_segment_index)
		var tip: Vector2 = origin + current_segment_direction * current_segment_length_target
		line.set_point_position(current_segment_index + 1, tip)

		var segment_angle: float = Math.random_weighted_range(segment_angle_avg, segment_angle_range, segment_angle_easing)
		segment_angle = deg2rad(segment_angle * Math.random_sign())

		line.add_point(tip)
		current_segment_index += 1
		current_segment_length = 0.0
		current_segment_direction = current_segment_direction.rotated(segment_angle)
		current_segment_length_target = Math.random_weighted_range(segment_length_avg, segment_length_range, segment_length_easing)
		is_new_segment = true

	length += branch_amount

	var origin: Vector2 = line.get_point_position(current_segment_index)
	var tip: Vector2 = origin + current_segment_direction * new_segment_length
	line.set_point_position(current_segment_index + 1, tip)
	current_segment_length = new_segment_length

	line.width = max(length * aspect_ratio, min_width) if length > 0.0 else min_width

	if is_new_segment:
		if randf() <= branchiness:
			add_branch(current_segment_index)
		elif randf() <= leafiness:
			add_leaf(current_segment_index)
