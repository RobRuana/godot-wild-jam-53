extends Node


const TWO_PI: float = 2.0 * PI
const THREE_QUARTER_PI: float = 0.75 * PI
const HALF_PI: float = 0.5 * PI
const QUARTER_PI: float = 0.25 * PI
const SIXTH_PI: float = 0.1666666667 * PI
const EIGHTH_PI: float = 0.125 * PI
const SQRT_TWO: float = 1.4142135624
const HALF_SQRT_TWO: float = 0.7071067812


func ease_in_out(n: float) -> float:
	return 0.5 + (sin((clamp(n, 0.0, 1.0) - 0.5) * PI) * 0.5)

func ease_in_out_mix(f1: float, f2: float, n: float) -> float:
	return lerp(f1, f2, ease_in_out(n))

func ease_in_out_mix_v(v1: Vector2, v2: Vector2, n: float) -> Vector2:
	return lerp(v1, v2, ease_in_out(n))

func ease_in(n: float) -> float:
	return 1.0 + sin((clamp(n, 0.0, 1.0) - 1.0) * HALF_PI)

func ease_in_mix(f1: float, f2: float, n: float) -> float:
	return lerp(f1, f2, ease_in(n))

func ease_out(n: float) -> float:
	return sin(clamp(n, 0.0, 1.0) * HALF_PI)

func ease_out_mix(f1: float, f2: float, n: float) -> float:
	return lerp(f1, f2, ease_out(n))


func closest_equivalent_angle(from: float, to: float) -> float:
	var delta: float = to - from
	if delta >= PI:
		return to - TWO_PI
	elif delta <= -PI:
		return to + TWO_PI
	return to


func closest_equivalent_rotation(from: Vector2, to: Vector2) -> Vector2:
	return Vector2(
		closest_equivalent_angle(from.x, to.x),
		closest_equivalent_angle(from.y, to.y)
	)


func is_zero_approx_v(vector: Vector2) -> bool:
	return is_zero_approx(vector.x) and is_zero_approx(vector.y)


func is_equal_approx_v(v1: Vector2, v2: Vector2) -> bool:
	return is_equal_approx(v1.x, v2.x) and is_equal_approx(v1.y, v2.y)


func is_circle_outside_rect(circle_position: Vector2, circle_radius: float, rect: Rect2) -> bool:
	var circle_bottom: = Vector2(circle_position.x, circle_position.y + circle_radius)
	var circle_top: = Vector2(circle_position.x, circle_position.y - circle_radius)
	var circle_left: = Vector2(circle_position.x - circle_radius, circle_position.y)
	var circle_right: = Vector2(circle_position.x + circle_radius, circle_position.y)

	if (
		rect.position.x > circle_right.x or
		rect.end.x < circle_left.x or
		rect.position.y > circle_bottom.y or
		rect.end.y < circle_top.y
	):
		return true

	if (
		rect.has_point(circle_position) or
		rect.has_point(circle_bottom) or
		rect.has_point(circle_top) or
		rect.has_point(circle_left) or
		rect.has_point(circle_right) or
		circle_position.distance_to(rect.position) < circle_radius or
		circle_position.distance_to(rect.end) < circle_radius or
		circle_position.distance_to(Vector2(rect.position.x, rect.end.y)) < circle_radius or
		circle_position.distance_to(Vector2(rect.end.x, rect.position.y)) < circle_radius
	):
		return false
	return true


func rect_corners(rect: Rect2) -> PoolVector2Array:
	var corners: PoolVector2Array = [
		rect.position,
		Vector2(rect.end.x, rect.position.y),
		rect.end,
		Vector2(rect.position.x, rect.end.y),
	]
	return corners


func rect_segments(rect: Rect2) -> Array:
	var segments: Array = [
		[rect.position, Vector2(rect.end.x, rect.position.y)],
		[Vector2(rect.end.x, rect.position.y), rect.end],
		[rect.end, Vector2(rect.position.x, rect.end.y)],
		[Vector2(rect.position.x, rect.end.y), rect.position],
	]
	return segments



func segment_intersects_rect(from: Vector2, to: Vector2, rect: Rect2):
	for segment in rect_segments(rect):
		var intersection = Geometry.segment_intersects_segment_2d(from, to, segment[0], segment[1])
		if intersection:
			return intersection
	return null
