extends Node


func _ready():
	set_process_unhandled_input(OS.is_debug_build())


func _unhandled_input(event):
	if event.is_action_released("debug_restart"):
		Events.reset_once()
		get_tree().reload_current_scene()

	elif event.is_action_released("debug_timescale_up"):
		Engine.time_scale *= 2.0

	elif event.is_action_released("debug_timescale_down"):
		Engine.time_scale *= 0.5
