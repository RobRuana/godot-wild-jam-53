tool
class_name Branch
extends Node2D


signal leaf_added(parent_branch, leaf)
signal branch_added(parent_branch, branch)


export var aspect_ratio: float = 1.0 / 15.0
export var min_width: float = 2.0

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
export var leaf_stem_length_ratio_easing: float = 0.05

export var segment_length_avg: float = 100.0
export var segment_length_range: float = 20.0
export var segment_length_easing: float = 2.0
export var segment_length_attenuation: float = 0.95

export var segment_angle_avg: float = 15.0
export var segment_angle_range: float = 5.0
export var segment_angle_easing: float = 2.0
export var segment_angle_attenuation: float = 1.05

export var max_segments_avg: float = 10.0
export var max_segments_range: float = 5.0
export var max_segments_easing: float = 2.0
export var max_segments_attenuation: float = 0.9

onready var leaves: Node2D = $Leaves
onready var branches: Node2D = $Branches
onready var line: Line2D = $Line2D

var parent_segment_index: int = 0
var parent_branch: Branch
var max_segments: int = 0
var current_segment_index: int = 0
var current_segment_length: float = 0.0
var current_segment_direction: Vector2 = Vector2.UP
var current_segment_length_target: float = 0.0

#var segment_lengths: Dictionary = {}
#var cumulative_segment_lengths: Dictionary = {}

var length: float = 0.0
var bbox: Rect2
var is_ready: bool = false


func set_origin_color(color: Color):
	line.gradient.set_color(0, color)


func set_tip_color(color: Color):
	line.gradient.set_color(1, color)


func get_origin_color() -> Color:
	return get_color_at_offset(0.0)


func get_tip_color() -> Color:
	return get_color_at_offset(1.0)


func get_color_at_offset(offset: float) -> Color:
	return line.gradient.interpolate(offset)


func get_origin_width() -> float:
	return get_width_at_offset(0.0)


func get_tip_width() -> float:
	return get_width_at_offset(1.0)


func get_width_at_offset(offset: float) -> float:
	return line.width * line.width_curve.interpolate_baked(offset)


func _ready() -> void:
	while line.get_point_count() < 2:
		line.add_point(Vector2.ZERO)
	is_ready = true


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
	var leaf: Leaf = Global.LEAF_SCENE.instance()
	leaf.parent_segment_index = segment_index
	leaf.parent_branch = self

	leaf.mature_length = Math.random_weighted_range(leaf_mature_length_avg, leaf_mature_length_range, leaf_mature_length_easing)
	leaf.lobe_aspect_ratio = Math.random_weighted_range(leaf_lobe_aspect_ratio_avg, leaf_lobe_aspect_ratio_range, leaf_lobe_aspect_ratio_easing)
	leaf.stem_length_ratio = Math.random_weighted_range(leaf_stem_length_ratio_avg, leaf_stem_length_ratio_range, leaf_stem_length_ratio_easing)

	leaf.position = line.get_point_position(segment_index)
	leaf.rotation = get_outside_bisection(segment_index, 0.5)
	leaves.add_child(leaf)
	emit_signal("leaf_added", self, leaf)


func add_branch(segment_index: int):
	var branch = Global.BRANCH_SCENE.instance() # Branch
	branch.parent_segment_index = segment_index
	branch.parent_branch = self

	branch.aspect_ratio = aspect_ratio
	branch.min_width = min_width
	branch.branchiness = branchiness
	branch.leafiness = leafiness

	branch.leaf_mature_length_avg = leaf_mature_length_avg
	branch.leaf_mature_length_range = leaf_mature_length_range
	branch.leaf_mature_length_easing = leaf_mature_length_easing

	branch.leaf_lobe_aspect_ratio_avg = leaf_lobe_aspect_ratio_avg
	branch.leaf_lobe_aspect_ratio_range = leaf_lobe_aspect_ratio_range
	branch.leaf_lobe_aspect_ratio_easing = leaf_lobe_aspect_ratio_easing

	branch.leaf_stem_length_ratio_avg = leaf_stem_length_ratio_avg
	branch.leaf_stem_length_ratio_range = leaf_stem_length_ratio_range
	branch.leaf_stem_length_ratio_easing = leaf_stem_length_ratio_easing

	branch.max_segments_avg = max_segments_avg * max_segments_attenuation
	branch.max_segments_range = max_segments_range * max_segments_attenuation
	branch.max_segments_easing = max_segments_easing
	branch.max_segments_attenuation = max_segments_attenuation

	branch.segment_length_avg = segment_length_avg * segment_length_attenuation
	branch.segment_length_range = segment_length_range * segment_length_attenuation
	branch.segment_length_easing = segment_length_easing
	branch.segment_length_attenuation = segment_length_attenuation

	branch.segment_angle_avg = segment_angle_avg * segment_angle_attenuation
	branch.segment_angle_range = segment_angle_range * segment_angle_attenuation
	branch.segment_angle_easing = segment_angle_easing
	branch.segment_angle_attenuation = segment_angle_attenuation

	branch.position = line.get_point_position(segment_index)
	branches.add_child(branch)
	emit_signal("branch_added", self, branch)


func grow(amount: float) -> Rect2:
	if !is_ready:
		return bbox

	if max_segments <= 0:
		max_segments = int(round(Math.random_weighted_range(max_segments_avg, max_segments_range, max_segments_easing)))

	if current_segment_length_target <= 0.0:
		current_segment_length_target = Math.random_weighted_range(segment_length_avg, segment_length_range, segment_length_easing)

#	var branch_amount: float = amount / float(branches.get_child_count() + leaves.get_child_count() + 1.0)
	var branch_amount: float = amount

	for branch in branches.get_children():
		var branch_color: Color = get_color_at_offset((float(branch.parent_segment_index) / float(current_segment_index + 1)))
		branch.grow(branch_amount)
		branch.set_origin_color(branch_color)
		var branch_bbox: Rect2 = branch.bbox
		branch_bbox.position += branch.position
		bbox = bbox.merge(branch_bbox)

	var is_new_segment: bool = false
	var new_segment_length: float = current_segment_length + branch_amount
	if new_segment_length >= current_segment_length_target:
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
	bbox = bbox.expand(tip)

	line.width = max(length * aspect_ratio, min_width) if length > 0.0 else min_width

	for leaf in leaves.get_children():
		leaf.grow(branch_amount)
		var leaf_offset: float = float(leaf.parent_segment_index) / float(current_segment_index + 1)
		var branch_width: float = get_width_at_offset(leaf_offset)
		var branch_color: Color = get_color_at_offset(leaf_offset)
		leaf.set_branch_width(branch_width)
		leaf.set_origin_color(branch_color)
		bbox = bbox.merge(leaf.transform.xform(leaf.bbox))

	if is_new_segment:
		if randf() <= branchiness:
			add_branch(current_segment_index)
		elif randf() <= leafiness:
			add_leaf(current_segment_index)

	return bbox
