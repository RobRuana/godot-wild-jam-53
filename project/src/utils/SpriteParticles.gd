class_name SpriteParticles
extends Particles2D


export var emission_origin: Vector2 setget set_emission_origin
export var emission_direction: Vector2 setget set_emission_direction
export var fade_delay: float = 0.0 setget set_fade_delay
export var gravity: Vector2 setget set_gravity
export var sprite_velocity: Vector2 setget set_sprite_velocity
export var initial_linear_velocity: float = 2.0 setget set_initial_linear_velocity
export var initial_angle_random: float = 1.0 setget set_initial_angle_random
export var pixels_per_particle: float = 2.0 setget set_pixels_per_particle
export var sprite_copies: int = 2 setget set_sprite_copies
export var use_fill_color: bool = false
export var use_outline_color_alt: bool = false
export var tween_time: float = 0.2
export var source_texture: Texture setget set_source_texture
var source_sprite: Sprite setget set_source_sprite
var has_shader_material: bool = false

onready var tween: Tween = $Tween

func _init():
	process_material = ShaderMaterial.new()
	process_material.shader = preload("res://src/shaders/pixel_explode.shader")

func _ready():
	explosiveness = 1.0
	one_shot = true

	self.sprite_velocity = sprite_velocity
	self.sprite_copies = sprite_copies
	self.emission_origin = emission_origin
	self.emission_direction = emission_direction
	self.fade_delay = fade_delay
	self.gravity = gravity
	self.initial_linear_velocity = initial_linear_velocity
	self.initial_angle_random = initial_angle_random
	self.pixels_per_particle = pixels_per_particle
	self.source_sprite = source_sprite

func set_emission_origin(value: Vector2):
	emission_origin = value
	if process_material:
		value = transform.basis_xform(emission_origin)
		process_material.set_shader_param("emission_origin", value)

func set_emission_direction(value: Vector2):
	emission_direction = value
	if process_material:
		process_material.set_shader_param("emission_direction", emission_direction)

func set_fade_delay(value: float):
	fade_delay = value
	if process_material:
		process_material.set_shader_param("fade_delay", fade_delay)

func set_gravity(value: Vector2):
	gravity = value
	if process_material:
		var g = transform.basis_xform_inv(value)
		process_material.set_shader_param("gravity", Vector3(g.x, g.y, 0.0))

func set_pixels_per_particle(value: float):
	pixels_per_particle = value
	if process_material:
		var texture_size: float = float(texture.get_width()) if texture else 1.0
		process_material.set_shader_param("scale", pixels_per_particle / texture_size)
		process_material.set_shader_param("pixels_per_particle", Vector2(pixels_per_particle, pixels_per_particle))
	var sprite_size: Vector2 = get_sprite_size()
	self.amount = int(sprite_copies * ceil(sprite_size.x / pixels_per_particle) * ceil(sprite_size.y / pixels_per_particle))

func set_initial_linear_velocity(value: float):
	initial_linear_velocity = value
	if process_material:
		process_material.set_shader_param("initial_linear_velocity", initial_linear_velocity)

func set_initial_angle_random(value: float):
	initial_angle_random = value
	if process_material:
		process_material.set_shader_param("initial_angle_random", initial_angle_random)

func set_sprite_velocity(value: Vector2):
	sprite_velocity = value
	if process_material:
		value = transform.basis_xform(sprite_velocity)
		process_material.set_shader_param("sprite_velocity", value)

func set_sprite_copies(value: int):
	sprite_copies = value
	if process_material:
		process_material.set_shader_param("sprite_copies", sprite_copies)
	var sprite_size: Vector2 = get_sprite_size()
	self.amount = int(sprite_copies * ceil(sprite_size.x / pixels_per_particle) * ceil(sprite_size.y / pixels_per_particle))

func set_source_texture(value: Texture):
	source_texture = value
	if source_texture:
		var sprite_size: Vector2 = source_texture.get_size()
		var sprite_extents: Vector2 = sprite_size * 0.5
		process_material.set_shader_param("sprite", source_texture)
		process_material.set_shader_param("emission_box_extents", Vector3(sprite_extents.x, sprite_extents.y, 1.0))
		process_material.set_shader_param("sprite_region_size", sprite_size)
		process_material.set_shader_param("sprite_region_position", Vector2.ZERO)
		self.sprite_copies = sprite_copies
		has_shader_material = false

func set_source_sprite(value: Sprite):
	source_sprite = value
	if source_sprite:
		self.global_transform = source_sprite.global_transform

		var sprite_size: Vector2 = Img.get_display_size(source_sprite)
		var sprite_extents: Vector2 = sprite_size * 0.5
		process_material.set_shader_param("sprite", source_sprite.texture)
		process_material.set_shader_param("emission_box_extents", Vector3(sprite_extents.x, sprite_extents.y, 1.0))
		process_material.set_shader_param("sprite_region_size", sprite_size)
		if source_sprite.region_enabled:
			process_material.set_shader_param("sprite_region_position", source_sprite.region_rect.position)
		else:
			process_material.set_shader_param("sprite_region_position", Vector2.ZERO)

		self.sprite_copies = sprite_copies
		has_shader_material = false

		if process_material and source_sprite.material:
			has_shader_material = true
			var shader_material = source_sprite.material
			var palette_texture = shader_material.get_shader_param("palette_texture")
			var palette_mix = shader_material.get_shader_param("palette_mix") if palette_texture != null else 0.0

			var outline_color = shader_material.get_shader_param("outline_color")
			var outline_mix = shader_material.get_shader_param("outline_mix") if outline_color != null else 0.0

			var fill_color = shader_material.get_shader_param("fill_color")
			var fill_mix = shader_material.get_shader_param("fill_mix") if fill_color != null else 0.0

			var outline_color_alt = shader_material.get_shader_param("outline_color_alt")
			var outline_color_alt_mix = shader_material.get_shader_param("outline_color_alt_mix") if outline_color_alt != null else 0.0

			process_material.set_shader_param("outline_mix", outline_mix)
			process_material.set_shader_param("outline_color", outline_color)
			process_material.set_shader_param("outline_color_alt", outline_color_alt)
			process_material.set_shader_param("outline_color_alt_mix", outline_color_alt_mix)
			process_material.set_shader_param("palette_mix", palette_mix)
			process_material.set_shader_param("palette_texture", palette_texture)
			process_material.set_shader_param("palette_texture_alt", shader_material.get_shader_param("palette_texture_alt"))
			process_material.set_shader_param("palette_texture_alt_mix", shader_material.get_shader_param("palette_texture_alt_mix"))
			process_material.set_shader_param("fill_color", fill_color)
			process_material.set_shader_param("fill_mix", fill_mix)

func emit_particles():
	if process_material and has_shader_material:
		if not use_fill_color:
			tween.interpolate_property(process_material, "shader_param/fill_mix", null, 0.0, tween_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		if not use_outline_color_alt:
			tween.interpolate_property(process_material, "shader_param/outline_color_alt_mix", null, 0.0, tween_time, Tween.TRANS_QUAD, Tween.EASE_IN_OUT)
		if not use_fill_color or not use_outline_color_alt:
			tween.start()
	emitting = true

func get_sprite_size() -> Vector2:
	if source_sprite:
		return Img.get_display_size(source_sprite)
	if source_texture:
		return source_texture.get_size()
	return Vector2.ONE
