tool
class_name Branch
extends Node2D


signal leaf_added(parent_branch, leaf)
signal branch_added(parent_branch, branch)


export var branch_aspect_ratio: float = 1.0 / 15.0
export var branch_min_width: float = 2.0

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

export var leaf_angle_bias_avg: float = 0.3 # 0.0 is full up, 1.0 is full down, 0.5 is bisection
export var leaf_angle_bias_range: float = 0.05
export var leaf_angle_bias_easing: float = 1.0

export var branch_angle_bias_avg: float = 0.5 # 0.0 is full up, 1.0 is bisection
export var branch_angle_bias_range: float = 0.1
export var branch_angle_bias_easing: float = 1.0

export var segment_length_avg: float = 100.0
export var segment_length_range: float = 20.0
export var segment_length_easing: float = 2.0

export var segment_angle_avg: float = 15.0
export var segment_angle_range: float = 5.0
export var segment_angle_easing: float = 2.0

export var max_segments_avg: float = 10.0
export var max_segments_range: float = 5.0
export var max_segments_easing: float = 2.0

onready var leaves: Node2D = $Leaves
onready var branches: Node2D = $Branches
onready var line: Line2D = $Line2D

var total_segment_index: int = 0
var parent_segment_index: int = 0
var parent_branch: Branch
var max_segments: int = 0
var current_segment_index: int = 0
var current_segment_length_target: float = 0.0

var segment_angles: Dictionary = {0: Vector2.UP.angle()}
var segment_directions: Dictionary = {0: Vector2.UP}
var segment_lengths: Dictionary = {0: 0.0}
var cumulative_segment_lengths: Dictionary = {0: 0.0}


var bbox: Rect2
var is_ready: bool = false
var is_mature: bool = false
var is_initialized: bool = false


func get_segment_offset(segment_index: int) -> float:
	var length: float = get_total_length()
	return cumulative_segment_lengths.get(segment_index - 1, 0.0) / length if length > 0.0 else 0.0


func set_origin_color(color: Color):
	line.gradient.set_color(0, color)


func set_tip_color(color: Color):
	line.gradient.set_color(1, color)


func get_origin_color() -> Color:
	return get_color_at_offset(0.0)


func get_tip_color() -> Color:
	return get_color_at_offset(1.0)


func get_color_at_segment(segment_index: int) -> Color:
	return get_color_at_offset(get_segment_offset(segment_index))


func get_color_at_offset(offset: float) -> Color:
	return line.gradient.interpolate(offset)


func get_origin_width() -> float:
	return get_width_at_offset(0.0)


func get_tip_width() -> float:
	return get_width_at_offset(1.0)


func get_width_at_segment(segment_index: int) -> float:
	return get_width_at_offset(get_segment_offset(segment_index))


func get_width_at_offset(offset: float) -> float:
	return line.width * line.width_curve.interpolate_baked(offset)


func get_tip_angle() -> float:
	return segment_angles.get(current_segment_index, 0.0)


func get_tip_direction() -> Vector2:
	return segment_directions.get(current_segment_index, 0.0)


func get_current_segment_length() -> float:
	return segment_lengths.get(current_segment_index, 0.0)


func get_total_segment_count() -> int:
	return total_segment_index + current_segment_index + 1


func get_total_length() -> float:
	return get_cumulative_length(current_segment_index)


func get_cumulative_length(segment_index: int) -> float:
	return cumulative_segment_lengths.get(segment_index, 0.0)


func get_outside_bisection(segment_index: int, weight: float = 0.5):
	var angle1: float = segment_angles[segment_index - 1]
	var angle2: float = segment_angles[segment_index]
	var obtuse_angle: float = Math.complementary_obtuse_angle(angle1 - angle2)
	var bisection: float = angle1 + lerp(0.0, obtuse_angle, weight)
	return bisection


func _ready() -> void:
	while line.get_point_count() < 2:
		line.add_point(Vector2.ZERO)
	is_ready = true


func initialize():
	# Set up some random variables that control how the plant grows
	max_segments = int(round(Math.random_weighted_range(max_segments_avg, max_segments_range, max_segments_easing)))
	current_segment_length_target = Math.random_weighted_range(segment_length_avg, segment_length_range, segment_length_easing)
	is_initialized = true


static func create_branch(parent):
	var branch = Global.BRANCH_SCENE.instance() # Branch
	branch.branch_aspect_ratio = parent.get("branch_aspect_ratio")
	branch.branch_min_width = parent.get("branch_min_width")
	branch.branchiness = parent.get("branchiness")
	branch.leafiness = parent.get("leafiness")
	branch.leaf_mature_length_avg = parent.get("leaf_mature_length_avg")
	branch.leaf_mature_length_range = parent.get("leaf_mature_length_range")
	branch.leaf_mature_length_easing = parent.get("leaf_mature_length_easing")
	branch.leaf_lobe_aspect_ratio_avg = parent.get("leaf_lobe_aspect_ratio_avg")
	branch.leaf_lobe_aspect_ratio_range = parent.get("leaf_lobe_aspect_ratio_range")
	branch.leaf_lobe_aspect_ratio_easing = parent.get("leaf_lobe_aspect_ratio_easing")
	branch.leaf_stem_length_ratio_avg = parent.get("leaf_stem_length_ratio_avg")
	branch.leaf_stem_length_ratio_range = parent.get("leaf_stem_length_ratio_range")
	branch.leaf_stem_length_ratio_easing = parent.get("leaf_stem_length_ratio_easing")
	branch.leaf_angle_bias_avg = parent.get("leaf_angle_bias_avg")
	branch.leaf_angle_bias_range = parent.get("leaf_angle_bias_range")
	branch.leaf_angle_bias_easing = parent.get("leaf_angle_bias_easing")
	branch.branch_angle_bias_avg = parent.get("branch_angle_bias_avg")
	branch.branch_angle_bias_range = parent.get("branch_angle_bias_range")
	branch.branch_angle_bias_easing = parent.get("branch_angle_bias_easing")
	branch.max_segments_avg = parent.get("max_segments_avg")
	branch.max_segments_range = parent.get("max_segments_range")
	branch.max_segments_easing = parent.get("max_segments_easing")
	branch.segment_length_avg = parent.get("segment_length_avg")
	branch.segment_length_range = parent.get("segment_length_range")
	branch.segment_length_easing = parent.get("segment_length_easing")
	branch.segment_angle_avg = parent.get("segment_angle_avg")
	branch.segment_angle_range = parent.get("segment_angle_range")
	branch.segment_angle_easing = parent.get("segment_angle_easing")
	return branch


func add_leaf(segment_index: int):
	var leaf: Leaf = Global.LEAF_SCENE.instance()
	leaf.parent_segment_index = segment_index
	leaf.total_segment_index = total_segment_index + segment_index
	leaf.parent_branch = self

	leaf.mature_length = Math.random_weighted_range(leaf_mature_length_avg, leaf_mature_length_range, leaf_mature_length_easing)
	leaf.lobe_aspect_ratio = Math.random_weighted_range(leaf_lobe_aspect_ratio_avg, leaf_lobe_aspect_ratio_range, leaf_lobe_aspect_ratio_easing)
	leaf.stem_length_ratio = Math.random_weighted_range(leaf_stem_length_ratio_avg, leaf_stem_length_ratio_range, leaf_stem_length_ratio_easing)

	var bias: float = Math.random_weighted_range(leaf_angle_bias_avg, leaf_angle_bias_range, leaf_angle_bias_easing)
	leaf.position = line.get_point_position(segment_index)
	leaf.rotation = get_tip_angle() if is_mature else get_outside_bisection(segment_index, bias)
	leaves.add_child(leaf)
	emit_signal("leaf_added", self, leaf)


func add_branch(segment_index: int):
	var branch = create_branch(self)
	branch.parent_segment_index = segment_index
	branch.total_segment_index = total_segment_index + segment_index
	branch.parent_branch = self
	branch.position = line.get_point_position(segment_index)

	var curr_angle: float = segment_angles[current_segment_index]
	var prev_angle: float = segment_angles[current_segment_index - 1]
	var angle: float = deg2rad(Math.random_weighted_range(segment_angle_avg, segment_angle_range, segment_angle_easing))
	var up_angle: float = prev_angle + angle * sign(prev_angle - curr_angle)
	var bisect_angle: float = get_outside_bisection(segment_index, 0.5)
	var bias: float = Math.random_weighted_range(branch_angle_bias_avg, branch_angle_bias_range, branch_angle_bias_easing)
	branch.segment_angles[0] = lerp(up_angle, bisect_angle, bias)
	branch.segment_directions[0] = Math.angle_to_vector(branch.segment_angles[0])

	branches.add_child(branch)
	emit_signal("branch_added", self, branch)


func move_tip(segment_length: float) -> Vector2:
	var origin: Vector2 = line.get_point_position(current_segment_index)
	var tip: Vector2 = origin + (segment_length * get_tip_direction())
	line.set_point_position(current_segment_index + 1, tip)
	bbox = bbox.expand(tip)
	segment_lengths[current_segment_index] = segment_length
	if current_segment_index <= 0:
		cumulative_segment_lengths[current_segment_index] = segment_length
	else:
		cumulative_segment_lengths[current_segment_index] = segment_length + cumulative_segment_lengths[current_segment_index - 1]
	return tip


func grow(amount: float) -> Rect2:
	if !is_ready:
		return bbox

	if !is_initialized:
		initialize()

	var new_segment_length: float = get_current_segment_length() + amount
	while get_total_segment_count() < max_segments and new_segment_length >= current_segment_length_target:
		new_segment_length -= current_segment_length_target

		var tip: Vector2 = move_tip(current_segment_length_target)

		var angle: float = deg2rad(Math.random_weighted_range(segment_angle_avg, segment_angle_range, segment_angle_easing))
		angle = angle * Math.random_sign()

		line.add_point(tip)
		current_segment_index += 1
		segment_angles[current_segment_index] = segment_angles[current_segment_index - 1] + angle
		segment_directions[current_segment_index] = segment_directions[current_segment_index - 1].rotated(angle)
		current_segment_length_target = Math.random_weighted_range(segment_length_avg, segment_length_range, segment_length_easing)

		if randf() <= branchiness:
			add_branch(current_segment_index)
		elif randf() <= leafiness:
			add_leaf(current_segment_index)

	if !is_mature:
		move_tip(new_segment_length)
		var length: float = get_total_length()
		line.width = max(length * branch_aspect_ratio, branch_min_width) if length > 0.0 else branch_min_width
		if get_total_segment_count() >= max_segments and get_current_segment_length() >= current_segment_length_target:
			is_mature = true
			add_leaf(current_segment_index + 1)

	for branch in branches.get_children():
		branch.grow(amount)
		branch.set_origin_color(get_color_at_segment(branch.parent_segment_index))
		var branch_bbox: Rect2 = branch.bbox
		branch_bbox.position += branch.position
		bbox = bbox.merge(branch_bbox)

	for leaf in leaves.get_children():
		leaf.grow(amount)
		leaf.set_branch_width(get_width_at_segment(leaf.parent_segment_index))
		leaf.set_origin_color(get_color_at_segment(leaf.parent_segment_index))
		bbox = bbox.merge(leaf.transform.xform(leaf.bbox))

	return bbox
