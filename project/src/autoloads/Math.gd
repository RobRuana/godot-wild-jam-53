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


func pow_ease_in(n: float, exponent: float) -> float:
	return pow(n, exponent)


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


# ========================================================
# Random functions
# ========================================================

func random_direction() -> Vector2:
	var t: float = randf() * TAU
	return Vector2(cos(t), sin(t))


func random_turn_angle(max_angle: float, pow_easing: float = 1.0) -> float:
	var turn_strength: float = randf()
	if (pow_easing != 1.0):
		turn_strength = pow_ease_in(turn_strength, pow_easing)
	var turn_direction: float = random_sign()
	return turn_direction * turn_strength * max_angle


func random_point_in_circle(radius_max: float, radius_min: float = 0.0) -> Vector2:
	var r2_max: float = radius_max * radius_max
	var r2_min: float = radius_min * radius_min
	var r: float = sqrt(randf() * (r2_max - r2_min) + r2_min)
	var t: float = randf() * TAU
	return Vector2(r * cos(t), r * sin(t))


func random_bit() -> int:
	return int(randi() % 2)


func random_bool() -> bool:
	return randi() % 2 == 0


func random_sign() -> float:
	return -1.0 if randi() % 2 == 0 else 1.0


# ========================================================
# Transform functions
# ========================================================

func is_flip_h(t: Transform2D) -> bool:
	# Possibly faster, potentially less acurate
	if (abs(t.y.x) < abs(t.y.y)):
		return (sign(t.x.x) * sign(t.y.y)) < 0.0
	else:
		return (sign(t.x.y) * sign(t.y.x)) > 0.0


func flip_h(t: Transform2D, flip: bool) -> Transform2D:
	# Could potentially assign negative zero (-0) to an x component
	var flip_sign: float = -1.0 if flip else 1.0
	t.x.x = abs(t.x.x) * sign(t.y.y) * flip_sign
	t.x.y = abs(t.x.y) * sign(t.y.x) * -flip_sign
	return t
