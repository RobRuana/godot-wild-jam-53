class_name TransitionImmediate
extends Transition


func push_transition(from_screen: CanvasItem, to_screen: CanvasItem):
	if from_screen:
		from_screen.visible = false
	to_screen.visible = true
	emit_signal("transition_completed")


func pop_transition(from_screen: CanvasItem, to_screen: CanvasItem):
	from_screen.visible = false
	if to_screen:
		to_screen.visible = true
	emit_signal("transition_completed")
