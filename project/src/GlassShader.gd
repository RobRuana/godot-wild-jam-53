tool
class_name GlassShader
extends TextureRect


export var drops_texture: Texture setget set_drops_texture


func set_drops_texture(value: Texture):
	drops_texture = value
	if Engine.editor_hint:
		material.set_shader_param("drops_texture", preload("res://assets/images/editor_raindrops.png"))
	else:
		material.set_shader_param("drops_texture", value)


func set_lightning(value: float):
	material.set_shader_param("lightning", value)
