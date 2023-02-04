class_name Goal
extends Node2D


signal letter_inside_goal(letter)


export var radius: float = 160.0 setget set_radius


var letters: Array = []


func set_radius(value: float):
	radius = value
	if has_node("Ring3"):
		var width: float = 2.0 * radius
		var size: = Vector2(width, width)
		$Ring2.rect_min_size = size
		$Ring2.rect_size = size
		$Ring2.rect_position = -size * 0.5

		size *= 0.8
		$Ring1.rect_min_size = size
		$Ring1.rect_size = size
		$Ring1.rect_position = -size * 0.5

		size *= 0.8
		$Ring0.rect_min_size = size
		$Ring0.rect_size = size
		$Ring0.rect_position = -size * 0.5

	if has_node("Area2D"):
		$Area2D/CollisionShape2D.shape.radius = radius


func _ready():
	$Area2D.connect("body_entered", self, "_on_body_entered")
	$Area2D.connect("body_exited", self, "_on_body_exited")


func _on_body_entered(body: Node):
	if body is LetterSprite:
		if body.state == Const.LetterSpriteState.NORMAL:
			letters.append(body)


func _on_body_exited(body: Node):
	if body is LetterSprite:
		letters.erase(body)


func is_letter_sprite_inside(letter_sprite: LetterSprite) -> bool:
	var letter_extents: Vector2 = letter_sprite.rect.size * 0.5
	var letter_radius: float = max(letter_extents.x, letter_extents.y)
	var letter_position: Vector2 = letter_sprite.global_position + letter_sprite.rect.position + letter_extents
	var goal_radius: float = max(radius - letter_radius, 1.0)
	var goal_radius_squared: float = goal_radius * goal_radius
	return letter_position.distance_squared_to(global_position) <= goal_radius_squared


func _physics_process(delta: float):
	for letter in letters:
		if letter.state == Const.LetterSpriteState.NORMAL and is_letter_sprite_inside(letter):
			letter.state = Const.LetterSpriteState.INSIDE_GOAL
			self.emit_signal("letter_inside_goal", letter)
			Events.emit_signal("letter_inside_goal", letter)
