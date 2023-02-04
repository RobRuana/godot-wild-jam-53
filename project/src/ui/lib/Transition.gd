class_name Transition
extends Node


signal start_transition_completed
signal transition_completed

var is_active: bool = false


func push_start_transition_from(from_screen: CanvasItem):
	emit_signal("start_transition_completed")


func push_transition(from_screen: CanvasItem, to_screen: CanvasItem):
	emit_signal("transition_completed")


func pop_start_transition_from(from_screen: CanvasItem):
	emit_signal("start_transition_completed")


func pop_transition(from_screen: CanvasItem, to_screen: CanvasItem):
	emit_signal("transition_completed")
