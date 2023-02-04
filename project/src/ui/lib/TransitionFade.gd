class_name TransitionFade
extends Transition


export var duration: float = 0.2
var fader: Fader


func _init():
	fader = Fader.new()
	add_child(fader)


func push_start_transition_from(from_screen: CanvasItem):
	is_active = true
	yield(fader.fade_to_transparent(from_screen, duration), "completed")
	is_active = false
	emit_signal("start_transition_completed")


func push_transition(from_screen: CanvasItem, to_screen: CanvasItem):
	is_active = true
	yield(fader.fade_to_opaque(to_screen, duration), "completed")
	is_active = false
	emit_signal("transition_completed")


func pop_start_transition_from(from_screen: CanvasItem):
	is_active = true
	yield(fader.fade_to_transparent(from_screen, duration), "completed")
	is_active = false
	emit_signal("start_transition_completed")


func pop_transition(from_screen: CanvasItem, to_screen: CanvasItem):
	if to_screen:
		is_active = true
		yield(fader.fade_to_opaque(to_screen, duration), "completed")
		is_active = false
	emit_signal("transition_completed")
