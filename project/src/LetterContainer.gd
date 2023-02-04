class_name LetterContainer
extends Node2D

const LETTER_SPRITE: PackedScene = preload("res://src/LetterSprite.tscn")
const OFFSCREEN_POINTER: PackedScene = preload("res://src/utils/OffscreenPointer.tscn")
const SPRITE_PARTICLES = preload("res://src/utils/SpriteParticles.tscn")

export var is_static: bool = false
export var letters: String = "" setget set_letters
export var letter_aggro_speed: float = 300.0 setget set_letter_aggro_speed
export var kerning: float = 10.0
export var default_modulate: Color = Color.white

var is_ready: bool = false
var goal: Goal


func set_letters(value: String):
	letters = value

	if Engine.editor_hint or not is_ready:
		return

	for child in get_children():
		remove_child(child)
		child.queue_free()

	var child_rects: Array = []
	var index: int = 0
	for letter in letters:
		letter = letter.replace(" ", "_").strip_edges()
		if letter.empty():
			continue

		var letter_sprite
		if is_static:
			letter_sprite = Sprite.new()
			letter_sprite.texture = Letters.get_letter_texture(letter)
		else:
			letter_sprite = LETTER_SPRITE.instance()
			letter_sprite.character_index = index
			letter_sprite.goal = goal
			letter_sprite.visible = false
			letter_sprite.aggro_speed = letter_aggro_speed
			letter_sprite.letter = letter

			var offscreen_pointer: OffscreenPointer = OFFSCREEN_POINTER.instance()
			letter_sprite.add_child(offscreen_pointer)
			offscreen_pointer.visible = false
			offscreen_pointer.color = Color(1.0, 1.0, 1.0, 0.5)
			offscreen_pointer.scale = Vector2(0.5, 0.5)

		letter_sprite.name = "%s_%s" % [Letters.get_letter_name(letter), index]
		letter_sprite.modulate = default_modulate
		add_child(letter_sprite)

		child_rects.push_back(Letters.get_letter_rect(letter))
		index += 1

	var child_sizes: = []
	var letter_count: = get_child_count()
	var total_width: float = kerning * float(letter_count - 1) * scale.x
	for child_rect in child_rects:
		child_sizes.append(child_rect.size * scale.x)
		total_width += child_rect.size.x * scale.x

	var cursor: Vector2 = global_position - Vector2(total_width * 0.5, 0.0)
	for i in range(get_child_count()):
		var child = get_child(i)
		var size: Vector2 = child_sizes[i]
		child.global_position = cursor + Vector2(size.x * 0.5, 0.0)
		if not is_static:
			child.destination = child.global_position
		cursor.x += size.x + (kerning * scale.x)


func set_letter_aggro_speed(value: float):
	letter_aggro_speed = value
	if not is_static:
		for child in get_children():
			child.aggro_speed = letter_aggro_speed


func _ready():
	is_ready = true
	self.letters = letters


func get_letter(character_index: int):
	return get_child(character_index)


func explode_letters():
	for letter in get_children():
		add_particles_for_letter(letter)
		letter.queue_free()
		remove_child(letter)
		yield(get_tree().create_timer(randf() * 0.2), "timeout")


func add_particles_for_letter(letter: LetterSprite):
	var sprite_particles = SPRITE_PARTICLES.instance()
	sprite_particles.source_sprite = letter.sprite
	sprite_particles.position = letter.position
	sprite_particles.modulate = letter.modulate
	sprite_particles.initial_linear_velocity = 6.0
	sprite_particles.lifetime = 2.0
	sprite_particles.sprite_velocity = letter.velocity * 0.2
	get_parent().add_child(sprite_particles)
	sprite_particles.emitting = true
	yield(get_tree().create_timer(sprite_particles.lifetime * 2.0), "timeout")
	sprite_particles.queue_free()
