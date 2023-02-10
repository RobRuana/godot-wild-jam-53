tool
class_name Glass
extends TextureRect


func set_lightning(value: float):
	material.set_shader_param("lightning", value)


func set_drops_texture(value: Texture):
	material.set_shader_param("drops_texture", value)
