extends Node

const RAIN_DROP: PackedScene = preload("res://src/Drop.tscn")

export(float, 0.0, 1.0) var heaviness: float
var num_drops: int = 30
var drops: Dictionary
var window_size: Vector2

func instantiate_drop():
	var drop = RAIN_DROP.instance()
	drops[drop.get_instance_id()] = drop
	var x_pos = rand_range(0, window_size.x)
	var y_pos = rand_range(0, window_size.y)
	drop.position = Vector2(x_pos, y_pos)
	drop.connect("drop_dead", self, "_on_drop_dead", [drop])
	add_child(drop)

func _ready():
	window_size = get_viewport().size
	for _n in range(num_drops):
		instantiate_drop()

func _on_drop_dead(drop):
	drops.erase(drop.get_instance_id())
