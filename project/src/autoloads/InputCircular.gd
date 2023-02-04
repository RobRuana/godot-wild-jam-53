extends Node

const threshold_low: float = 0.1
const threshold_low_squared: float = threshold_low * threshold_low
const threshold_high: float = 0.6
const threshold_high_squared: float = threshold_high * threshold_high
const threshold_range: float = threshold_high - threshold_low
const threshold_range_inverse: float = 1.0 / threshold_range


func get_action_strength(action: String = "move") -> Vector2:
	var strength: Vector2
	var direction: = get_raw(action)
	var length_squared: = direction.length_squared()
	if length_squared <= threshold_low_squared:
		return Vector2.ZERO
	elif length_squared >= threshold_high_squared:
		strength = direction.normalized()
	else:
		strength = direction.normalized() * (sqrt(length_squared) - threshold_low) * threshold_range_inverse

	if Math.is_zero_approx_v(strength):
		return Vector2.ZERO
	return strength


func get_action_direction(action: String = "move") -> Vector2:
	var direction: = get_raw(action)
	if direction.length_squared() <= threshold_low_squared:
		return Vector2.ZERO
	return direction.normalized()


func get_raw(action: String = "move") -> Vector2:
	return Vector2(get_x_raw(action), get_y_raw(action))


func has_move(action: String = "move") -> bool:
	return get_raw(action).length_squared() > threshold_low_squared


func get_x(action: String = "move") -> float:
	return get_action_strength(action).x


func get_x_raw(action: String = "move") -> float:
	return Input.get_action_strength(action + "_right") - Input.get_action_strength(action + "_left")


func has_x(action: String = "move") -> bool:
	var direction: Vector2 = get_raw()
	return not is_zero_approx(direction.x) and direction.length_squared() >= threshold_low_squared


func get_y(action: String = "move") -> float:
	return get_action_strength(action).y


func get_y_raw(action: String = "move") -> float:
	return Input.get_action_strength(action + "_down") - Input.get_action_strength(action + "_up")


func has_y(action: String = "move") -> bool:
	var direction: Vector2 = get_raw()
	return not is_zero_approx(direction.y) and direction.length_squared() >= threshold_low_squared
