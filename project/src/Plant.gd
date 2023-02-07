class_name Plant
extends Node2D


export(int, 1, 99) var root_count: int = 1
export(float, 0.0, 1.0) var branchiness: float = 0.2
export(float, 0.0, 1.0) var leafiness: float = 0.4


export var leaf_lobe_aspect_ratio: float = 0.6
export var leaf_stem_length_ratio: float = 0.2
export var leaf_mature_length: float = 100.0

export var branch_aspect_ratio: float = 0.05
export var branch_min_width: float = 2.0

export var branch_segment_length_avg: float = 100.0
export var branch_segment_length_range: float = 20.0
export var branch_segment_length_easing: float = 2.0
export var branch_segment_length_attenuation: float = 0.95

export var branch_segment_angle_avg: float = 15.0
export var branch_segment_angle_range: float = 5.0
export var branch_segment_angle_easing: float = 2.0
export var branch_segment_angle_attenuation: float = 1.05


onready var root_branches: Node2D = $"%RootBranches"

var branches: Dictionary = {}
var leaves: Dictionary = {}

var bbox: Rect2
var water: float = 0.0
var growth_rate: float = 100.0
var evaporation_rate: float = 1.0
var is_ready: bool = false


func _ready() -> void:
	for i in root_count:
		add_root_branch()
	is_ready = true


func add_root_branch():
	var branch = Global.BRANCH_SCENE.instance() # Branch
	branch.parent_segment_index = -1
	branch.branchiness = branchiness
	branch.leafiness = leafiness
	branch.aspect_ratio = branch_aspect_ratio
	branch.min_width = branch_min_width
	branch.segment_length_avg = branch_segment_length_avg * branch_segment_length_attenuation
	branch.segment_length_range = branch_segment_length_range * branch_segment_length_attenuation
	branch.segment_length_easing = branch_segment_length_easing
	branch.segment_length_attenuation = branch_segment_length_attenuation
	branch.segment_angle_avg = branch_segment_angle_avg * branch_segment_angle_attenuation
	branch.segment_angle_range = branch_segment_angle_range * branch_segment_angle_attenuation
	branch.segment_angle_easing = branch_segment_angle_easing
	branch.segment_angle_attenuation = branch_segment_angle_attenuation
	root_branches.add_child(branch)
	bind_branch(branch)


func bind_leaf(leaf: Leaf):
	leaves[leaf.get_instance_id()] = leaf
	if not leaf.is_connected("tree_exiting", self, "_on_leaf_tree_exiting"):
		leaf.connect("tree_exiting", self, "_on_leaf_tree_exiting", [leaf])
	if not leaf.is_connected("water_received", self, "_on_leaf_water_received"):
		leaf.connect("water_received", self, "_on_leaf_water_received")


func unbind_leaf(leaf: Leaf):
	leaves.erase(leaf.get_instance_id())
	if leaf.is_connected("tree_exiting", self, "_on_leaf_tree_exiting"):
		leaf.disconnect("tree_exiting", self, "_on_leaf_tree_exiting")
	if leaf.is_connected("water_received", self, "_on_leaf_water_received"):
		leaf.disconnect("water_received", self, "_on_leaf_water_received")


func bind_branch(branch: Branch):
	branches[branch.get_instance_id()] = branch
	if not branch.is_connected("tree_exiting", self, "_on_branch_tree_exiting"):
		branch.connect("tree_exiting", self, "_on_branch_tree_exiting", [branch])
	if not branch.is_connected("leaf_added", self, "_on_branch_leaf_added"):
		branch.connect("leaf_added", self, "_on_branch_leaf_added")
	if not branch.is_connected("branch_added", self, "_on_branch_branch_added"):
		branch.connect("branch_added", self, "_on_branch_branch_added")


func unbind_branch(branch: Branch):
	branches.erase(branch.get_instance_id())
	if branch.is_connected("tree_exiting", self, "_on_branch_tree_exiting"):
		branch.disconnect("tree_exiting", self, "_on_branch_tree_exiting")
	if branch.is_connected("leaf_added", self, "_on_branch_leaf_added"):
		branch.disconnect("leaf_added", self, "_on_branch_leaf_added")
	if branch.is_connected("branch_added", self, "_on_branch_branch_added"):
		branch.disconnect("branch_added", self, "_on_branch_branch_added")


func _on_leaf_tree_exiting(leaf: Leaf):
	unbind_leaf(leaf)


func _on_leaf_water_received(leaf: Leaf, amount: float):
	water += amount


func _on_branch_branch_added(parent_branch, branch):
	bind_branch(branch)


func _on_branch_leaf_added(parent_branch, leaf):
	bind_leaf(leaf)


func _on_branch_tree_exiting(branch): # Branch
	unbind_branch(branch)


func _physics_process(delta: float) -> void:
	if is_ready:
		water -= evaporation_rate * delta
		for root_branch in root_branches.get_children():
			bbox = bbox.merge(root_branch.grow(growth_rate * delta))
		update()


func _draw() -> void:
	draw_rect(bbox, Color.magenta, false, 4.0, false)
