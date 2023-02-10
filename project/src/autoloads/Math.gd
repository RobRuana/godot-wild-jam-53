tool
extends Node


const TWO_PI: float = 2.0 * PI
const THREE_QUARTER_PI: float = 0.75 * PI
const HALF_PI: float = 0.5 * PI
const QUARTER_PI: float = 0.25 * PI
const SEVEN_QUARTER_PI: float = 1.75 * PI
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


func get_acute_angle(v1: Vector2, v2: Vector2) -> float:
	return complementary_acute_angle(v1.angle_to(v2))


func complementary_acute_angle(angle: float) -> float:
	var abs_angle: float = abs(angle)
	if abs_angle == 0.0:
		return 0.0
	if abs_angle <= HALF_PI:
		return angle
	return sign(angle) * (PI - abs_angle)


func get_obtuse_angle(v1: Vector2, v2: Vector2) -> float:
	return complementary_obtuse_angle(v1.angle_to(v2))


func complementary_obtuse_angle(angle: float) -> float:
	var abs_angle: float = abs(angle)
	if abs_angle == 0.0:
		return PI
	if abs_angle > HALF_PI:
		return angle
	return sign(angle) * (PI - abs_angle)


func get_inside_angle(v1: Vector2, v2: Vector2) -> float:
	var angle: float = v1.angle_to(v2)
	var abs_angle: float = abs(angle)
	if abs_angle == 0.0:
		return 0.0
	if abs_angle <= PI:
		return angle
	return sign(angle) * (TWO_PI - abs_angle)


func get_outside_angle(v1: Vector2, v2: Vector2) -> float:
	var angle: float = v1.angle_to(v2)
	var abs_angle: float = abs(angle)
	if abs_angle == 0.0:
		return TWO_PI
	if abs_angle > PI:
		return angle
	return sign(angle) * (TWO_PI - abs_angle)


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


func bbox(array: PoolVector2Array) -> Rect2:
	if array.size() <= 0:
		return Rect2()

	var max_x: float = array[0].x
	var max_y: float = array[0].y
	var min_x: float = array[0].x
	var min_y: float = array[0].y
	for v in array:
		max_x = max(max_x, v.x)
		max_y = max(max_y, v.y)
		min_x = min(min_x, v.x)
		min_y = min(min_y, v.y)

	return Rect2(
		Vector2(min_x, min_y),
		Vector2(max_x - min_x, max_y - min_y)
	)


# ========================================================
# Random functions
# ========================================================

func random_bit() -> int:
	return int(randi() % 2)


func random_bool() -> bool:
	return randi() % 2 == 0


func random_direction() -> Vector2:
	var t: float = randf() * TAU
	return Vector2(cos(t), sin(t))


func random_point_in_circle(radius_max: float, radius_min: float = 0.0) -> Vector2:
	var r2_max: float = radius_max * radius_max
	var r2_min: float = radius_min * radius_min
	var r: float = sqrt(randf() * (r2_max - r2_min) + r2_min)
	var t: float = randf() * TAU
	return Vector2(r * cos(t), r * sin(t))


func random_sign() -> float:
	return -1.0 if randi() % 2 == 0 else 1.0


func random_turn_angle(max_angle: float, pow_easing: float = 1.0) -> float:
	var turn_strength: float = randf()
	if (pow_easing != 1.0):
		turn_strength = pow_ease_in(turn_strength, pow_easing)
	var turn_direction: float = random_sign()
	return turn_direction * turn_strength * max_angle


func random_weighted_between(lower: float, upper: float, pow_easing: float = 1.0) -> float:
	var center: float = (lower * 0.5) + (upper * 0.5)
	var range_extent: float = abs(upper - center)
	return random_weighted_range(center, range_extent, pow_easing)


func random_weighted_range(center: float, range_extent: float, pow_easing: float = 1.0) -> float:
	if is_zero_approx(range_extent):
		return center
	return center + (random_weighted_strength(pow_easing) * range_extent)


func random_weighted_strength(pow_easing: float = 1.0) -> float:
	# Returns a weighted random value from -1.0 to 1.0
	var rand: float = randf() - 0.5
	var direction: float = sign(rand)
	var strength: float = abs(rand) * 2.0
	if pow_easing != 1.0:
		strength = pow_ease_in(strength, pow_easing)
	return direction * strength


# ========================================================
# Polygon functions
# ========================================================

func angle_to_vector(angle: float) -> Vector2:
	return Vector2(cos(angle), sin(angle))


func make_arc_polygon(radius: float, start_angle: float, end_angle: float, center: Vector2, round_precision: int) -> PoolVector2Array:
	var polygon: PoolVector2Array = PoolVector2Array();
	if round_precision > 1:
		for i in round_precision:
			# Do not use lerp_angle() because it always chooses the shortest angle
			# float angle = lerp_angle(start_angle, end_angle, (float)i / (float)(round_precision - 1))
			var angle: float = lerp(start_angle, end_angle, float(i) / float(round_precision - 1))
			polygon.append(center + angle_to_vector(angle) * radius)
	else:
		# Do not use lerp_angle() because it always chooses the shortest angle
		# float angle = lerp_angle(start_angle, end_angle, (float)i / (float)(round_precision - 1))
		var angle: float = lerp(start_angle, end_angle, 0.5)
		polygon.append(center + angle_to_vector(angle) * radius)
	return polygon


func make_circle_polygon(radius: float, center: Vector2, round_precision: int) -> PoolVector2Array:
	var polygon: PoolVector2Array = PoolVector2Array();
	for i in round_precision:
		var angle: float = lerp(-PI, PI, float(i) / float(round_precision))
		polygon.append(center + angle_to_vector(angle) * radius)
	return polygon


func make_leaf_polygon(length: float, center: Vector2, round_precision: int) -> PoolVector2Array:
	var radius: float = length / (1.0 + SQRT_TWO)
	var polygon: PoolVector2Array = make_arc_polygon(radius, QUARTER_PI, SEVEN_QUARTER_PI, center, round_precision)
	polygon.append(Vector2(radius * SQRT_TWO, 0.0))
	return polygon


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


# ========================================================
# Numeric functions
# ========================================================

func move_toward_each_other(n1: float, n2: float, delta: float, allow_crossover: bool = false) -> Array:
	if not allow_crossover and abs(n2 - n1) * 0.5 <= delta:
		var center: float = 0.5 * (n1 + n2)
		return [center, center]
	return [move_toward(n1, n2, delta), move_toward(n2, n1, delta)]


func move_toward_each_other_x(p1: Vector2, p2: Vector2, delta: float, allow_crossover: bool = false) -> Array:
	var values: Array = move_toward_each_other(p1.x, p2.x, delta, allow_crossover)
	return [Vector2(values[0], p1.y), Vector2(values[1], p2.y)]


func move_toward_each_other_y(p1: Vector2, p2: Vector2, delta: float, allow_crossover: bool = false) -> Array:
	var values: Array = move_toward_each_other(p1.y, p2.y, delta, allow_crossover)
	return [Vector2(p1.x, values[0]), Vector2(p2.x, values[1])]


func move_toward_each_other_v(p1: Vector2, p2: Vector2, delta: float, allow_crossover: bool = false) -> Array:
	if not allow_crossover and p1.distance_to(p2) * 0.5 <= delta:
		var center: Vector2 = 0.5 * (p1 + p2)
		return [center, center]
	return [p1.move_toward(p2, delta), p2.move_toward(p1, delta)]


func evenly_spread(n1: float, n2: float, count: int) -> Array:
	var values: Array = [n1]
	var length: float = abs(n2 - n1)
	if count > 2:
		var spacing: float = length / float(count - 1)
		for i in range(1, count - 1):
			values.append(move_toward(n1, n2, spacing * float(i)))
	values.append(n2)
	return values


func evenly_spread_x(p1: Vector2, p2: Vector2, count: int) -> Array:
	var values: Array = []
	for value in evenly_spread(p1.x, p2.x, count):
		values.append(Vector2(value, range_lerp(value, p1.x, p2.x, p1.y, p2.y)))
	return values


func evenly_spread_y(p1: Vector2, p2: Vector2, count: int) -> Array:
	var values: Array = []
	for value in evenly_spread(p1.x, p2.x, count):
		values.append(Vector2(value, range_lerp(value, p1.x, p2.x, p1.y, p2.y)))
	return values


func evenly_spread_v(p1: Vector2, p2: Vector2, count: int) -> Array:
	var values: Array = [p1]
	var length: float = p1.distance_to(p2)
	if count > 2:
		var spacing: float = length / float(count - 1)
		for i in range(1, count - 1):
			values.append(p1.move_toward(p2, spacing * float(i)))
	values.append(p2)
	return values


func evenly_spaced(n1: float, n2: float, spacing: float) -> Array:
	var values: Array = [n1]
	var length: float = abs(n2 - n1)
	var count: int = 0
	if length > spacing:
		count = int(round(length / spacing))
		if count > 0:
			spacing = length / float(count)
	for i in range(1, count):
		values.append(move_toward(n1, n2, spacing * float(i)))
	values.append(n2)
	return values


func evenly_spaced_x(p1: Vector2, p2: Vector2, spacing: float) -> Array:
	var values: Array = []
	for value in evenly_spaced(p1.x, p2.x, spacing):
		values.append(Vector2(value, range_lerp(value, p1.x, p2.x, p1.y, p2.y)))
	return values


func evenly_spaced_y(p1: Vector2, p2: Vector2, spacing: float) -> Array:
	var values: Array = []
	for value in evenly_spaced(p1.y, p2.y, spacing):
		values.append(Vector2(range_lerp(value, p1.y, p2.y, p1.x, p2.x), value))
	return values


func evenly_spaced_v(p1: Vector2, p2: Vector2, spacing: float) -> Array:
	var values: Array = [p1]
	var length: float = p1.distance_to(p2)
	var count: int = 0
	if length > spacing:
		count = int(round(length / spacing))
		if count > 0:
			spacing = length / float(count)
	for i in range(1, count):
		values.append(p1.move_toward(p2, spacing * float(i)))
	values.append(p2)
	return values


func floor_snap(value: float, step: float) -> float:
	return floor(value / step) * step


func ceil_snap(value: float, step: float) -> float:
	return ceil(value / step) * step


func floor_snap_v(value: Vector2, step: Vector2) -> Vector2:
	return (value / step).floor() * step


func ceil_snap_v(value: Vector2, step: Vector2) -> Vector2:
	return (value / step).ceil() * step
