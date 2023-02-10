tool
class_name RainDrops
extends ColorRect


const RAIN_DROP_SCENE: PackedScene = preload("res://src/RainDrop.tscn")


var mouse_pressed: bool = false


func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			mouse_pressed = true
			var drop: RainDrop = RAIN_DROP_SCENE.instance()
			drop.position = get_global_mouse_position()
			drop.scale *= rand_range(0.5, 1.0)
			add_child(drop)
