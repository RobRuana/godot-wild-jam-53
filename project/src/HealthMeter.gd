tool
class_name HealthMeter
extends MarginContainer


const SPRITE_PARTICLES = preload("res://src/utils/SpriteParticles.tscn")

export var health: float = 1.0 setget set_health
export var icon_color: Color = Color(0.9, 0.0, 0.0, 1.0) setget set_icon_color
export var icon_texture: Texture setget set_icon_texture

onready var health_container: GridContainer = $HealthContainer


func set_health(value: float):
	health = value
	if health_container:
		var wish_child_count: = int(ceil(health)) if health > 0.0 else 0
		var children: = health_container.get_children()
		var child_count: = children.size()
		if wish_child_count > child_count:
			for i in range(wish_child_count - child_count):
				var health_icon: TextureRect = TextureRect.new()
				health_icon.name = "HealthIcon_%s" % (child_count + i)
				health_container.add_child(health_icon)
				health_icon.modulate = icon_color
				if icon_texture:
					health_icon.texture = icon_texture
		elif wish_child_count < child_count:
			for i in range(child_count - wish_child_count):
				children[-1 - i].queue_free()
				add_particles_for_icon(children[-1 - i])

		if children:
			var health_icon: TextureRect = children[0] as TextureRect
			var icon_size: = health_icon.texture.get_size()
			var cols: float = health_container.columns
			var rows: float = ceil(float(children.size()) / cols)
			var hsep: float = health_container.get("custom_constants/hseparation")
			var vsep: float = health_container.get("custom_constants/vseparation")
			self.rect_min_size = Vector2(
				(icon_size.x * cols) + (hsep * (cols - 1.0)),
				(icon_size.y * rows) + (vsep * (rows - 1.0))
			)
			self.rect_size = self.rect_min_size
		else:
			self.rect_min_size = Vector2.ZERO
			self.rect_size = Vector2.ZERO


func set_icon_color(value: Color):
	icon_color = value
	if health_container:
		var health_icons: = health_container.get_children()
		for health_icon in health_icons:
			health_icon.modulate = icon_color


func set_icon_texture(value: Texture):
	icon_texture = value
	if health_container and icon_texture:
		var health_icons: = health_container.get_children()
		for health_icon in health_icons:
			health_icon.texture = icon_texture


func _ready():
	self.health = health


func add_particles_for_icon(icon: TextureRect):
	var sprite_particles = SPRITE_PARTICLES.instance()
	sprite_particles.lifetime = 1.0
	sprite_particles.gravity = Vector2(0.0, 100.0)
	sprite_particles.sprite_velocity = Vector2(0.0, -20.0)
	sprite_particles.sprite_copies = 3
	sprite_particles.source_texture = icon.texture
	sprite_particles.position = icon.rect_position + (icon.rect_size * 0.5)
	sprite_particles.modulate = icon.modulate
	sprite_particles.initial_linear_velocity = 10.0
	add_child(sprite_particles)
	sprite_particles.emitting = true
	Global.safe_queue_free_remove_child(self, sprite_particles, sprite_particles.lifetime + 0.1)
