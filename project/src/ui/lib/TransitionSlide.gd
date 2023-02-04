class_name TransitionSlide
extends Transition


const TRANS: = Tween.TRANS_SINE
const EASE: = Tween.EASE_IN_OUT

export var duration: float = 0.3
var tween: Tween


func _init():
	tween = Tween.new()
	add_child(tween)


func push_transition(from_screen: CanvasItem, to_screen: CanvasItem):
	is_active = true

	if from_screen:
		var from_property: String = "rect_position" if from_screen is Control else "position"
		var from_end: = Vector2(-Global.screen_size.x, 0.0)
		tween.remove(from_screen, from_property)
		tween.interpolate_property(from_screen, from_property, null, from_end, duration, TRANS, EASE)

	var to_property: String = "rect_position" if to_screen is Control else "position"
	var to_start: = Vector2(Global.screen_size.x, 0.0)
	var to_end: = Vector2.ZERO
	to_screen.rect_position = to_start
	to_screen.visible = true
	tween.remove(to_screen, to_property)
	tween.interpolate_property(to_screen, to_property, to_start, to_end, duration, TRANS, EASE)

	tween.start()
	yield(tween, "tween_all_completed")

	is_active = false
	emit_signal("transition_completed")


func pop_transition(from_screen: CanvasItem, to_screen: CanvasItem):
	is_active = true

	var from_property: String = "rect_position" if from_screen is Control else "position"
	var from_end: = Vector2(Global.screen_size.x, 0.0)
	tween.remove(from_screen, from_property)
	tween.interpolate_property(from_screen, from_property, null, from_end, duration, TRANS, EASE)

	if to_screen:
		var to_property: String = "rect_position" if to_screen is Control else "position"
		var to_end: = Vector2.ZERO
		to_screen.visible = true
		tween.remove(to_screen, to_property)
		tween.interpolate_property(to_screen, to_property, null, to_end, duration, TRANS, EASE)

	tween.start()
	yield(tween, "tween_all_completed")

	is_active = false
	emit_signal("transition_completed")
