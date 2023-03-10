class_name Plant
extends Node2D


export(int, 1, 99) var root_count: int = 1
export var root_width: float = 200.0
export(float, 0.0, 1.0) var branchiness: float = 0.2
export(float, 0.0, 1.0) var leafiness: float = 0.4

export var leaf_mature_length_avg: float = 100.0
export var leaf_mature_length_range: float = 20.0
export var leaf_mature_length_easing: float = 2.0

export var leaf_lobe_aspect_ratio_avg: float = 0.6
export var leaf_lobe_aspect_ratio_range: float = 0.1
export var leaf_lobe_aspect_ratio_easing: float = 2.0

export var leaf_stem_length_ratio_avg: float = 0.2
export var leaf_stem_length_ratio_range: float = 0.05
export var leaf_stem_length_ratio_easing: float = 1.0

export var leaf_angle_bias_avg: float = 0.3 # 0.0 is full up, 1.0 is full down, 0.5 is half bisection
export var leaf_angle_bias_range: float = 0.05
export var leaf_angle_bias_easing: float = 1.0

export var branch_angle_bias_avg: float = 0.5 # 0.0 is full up, 1.0 is bisection
export var branch_angle_bias_range: float = 0.1
export var branch_angle_bias_easing: float = 1.0

export var branch_aspect_ratio: float = 0.05
export var branch_min_width: float = 2.0

export var segment_length_avg: float = 100.0
export var segment_length_range: float = 20.0
export var segment_length_easing: float = 2.0

export var segment_angle_avg: float = 15.0
export var segment_angle_range: float = 5.0
export var segment_angle_easing: float = 2.0

export var max_segments_avg: float = 10.0
export var max_segments_range: float = 5.0
export var max_segments_easing: float = 2.0

export var grow_interval: float = 0.05
export var growth_rate: float = 100.0


onready var grow_timer: Timer = $"%GrowTimer"
onready var root_branches: Node2D = $"%RootBranches"

var branches: Dictionary = {}
var leaves: Dictionary = {}

var bbox: Rect2
var water: float = 0.0
var is_ready: bool = false


func set_lightning(value: float):
	modulate = lerp(Color.white, Color.black, value)


func _ready() -> void:
	var positions: Array = [0.0]
	if root_count > 1:
		var root_extent: float = root_width * 0.5
		positions = Math.evenly_spread(-root_extent, root_extent, root_count)
	for x in positions:
		var branch = Branch.create_branch(self)
		branch.position.x = x
		root_branches.add_child(branch)
		bind_branch(branch)

	grow_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
	grow_timer.wait_time = grow_interval
	grow_timer.one_shot = true
	grow_timer.autostart = false
	if not grow_timer.is_connected("timeout", self, "_on_grow_timer_timeout"):
		grow_timer.connect("timeout", self, "_on_grow_timer_timeout")

	grow_timer.start(grow_interval)

	is_ready = true


func _on_grow_timer_timeout():
	if is_ready:
		var delta: float = grow_timer.wait_time
		for root_branch in root_branches.get_children():
			root_branch.grow(growth_rate * delta)
			var root_branch_bbox: Rect2 = root_branch.bbox
			root_branch_bbox.position += root_branch.position
			bbox = bbox.merge(root_branch_bbox)
#		update()
	grow_timer.start(grow_interval)


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


#func _draw() -> void:
#	# draw debug rectangle around bounding box
#	draw_rect(bbox, Color.magenta, false, 4.0, false)
