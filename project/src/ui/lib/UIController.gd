class_name UIController
extends Control


signal pop_controller_requested(controller)
signal pop_controller_completed(controller)
signal will_pop_screen(screen)
signal did_pop_screen(screen)
signal will_push_screen(screen)
signal did_push_screen(screen)
signal focus_entered_control(control)
signal focus_exited_control(control)
signal mouse_entered_control(control)
signal mouse_exited_control(control)
signal focusable_control_added(control)
signal focusable_control_removed(control)

const CONTROLLER_SIGNALS: Array = [
	"pop_controller_requested",
	"pop_controller_completed",
]

const SCREEN_SIGNALS: Array = [
	"will_pop_screen",
	"did_pop_screen",
	"will_push_screen",
	"did_push_screen",
]

const CONTROL_SIGNALS: Array = [
	"focus_entered_control",
	"focus_exited_control",
	"mouse_entered_control",
	"mouse_exited_control",
	"focusable_control_added",
	"focusable_control_removed",
]


export var default_transition: Resource = preload("res://src/ui/lib/TransitionFade.gd")

onready var screen_size: = get_viewport_rect().size
var screen_history: Array = []
onready var fader: Fader = $Fader
var transitioning: bool = false


func _ready():
	for child in get_children():
		if child is UIScreen:
			push_initial_screen(child)
			break


func pop_screen():
	if transitioning:
		return
	transitioning = true

	if screen_history.size() <= 1:
		emit_signal("pop_controller_requested", self)
		transitioning = false
		return

	var from_screen: UIScreen = screen_history[-1]
	from_screen.transitioning = true
	emit_signal("will_pop_screen", from_screen)
	from_screen.will_pop_screen()

	var transition: Transition
	if from_screen.transition:
		transition = from_screen.transition
	else:
		transition = Global.instance(default_transition)
		add_child(transition)

	transition.pop_start_transition_from(from_screen)
	if transition.is_active:
		yield(transition, "start_transition_completed")

	screen_history.pop_back()
	emit_signal("did_pop_screen", from_screen)
	from_screen.did_pop_screen()
	unbind_screen(from_screen)

	var to_screen: UIScreen = screen_history[-1]
	to_screen.transitioning = true
	to_screen.grab_focus()

	transition.pop_transition(from_screen, to_screen)
	if transition.is_active:
		yield(transition, "transition_completed")

	to_screen.transitioning = false
	from_screen.transitioning = false
	from_screen.queue_free()
	transition.queue_free()

	transitioning = false


func push_screen(path: String, transition_source: Resource = null, transition_properties: Dictionary = {}):
	if transitioning:
		return
	transitioning = true

	var transition: Transition
	if transition_source:
		transition = Global.instance(transition_source, transition_properties)
	else:
		transition = Global.instance(default_transition)
	add_child(transition)

	var from_screen: UIScreen
	if screen_history:
		from_screen = screen_history[-1]
		from_screen.transitioning = true
		transition.push_start_transition_from(from_screen)

	var packed_scene: PackedScene
	if OS.get_name() == "HTML5":
		if transition.is_active:
			yield(transition, "start_transition_completed")
		packed_scene = ResourceLoader.load(path)
	else:
		packed_scene = yield(ResourceQueue.load_async(path), "completed")
		if transition.is_active:
			yield(transition, "start_transition_completed")

	var to_screen: UIScreen = packed_scene.instance()

	to_screen.transitioning = true
	to_screen.visible = false
	add_child(to_screen)
	to_screen.transition = transition
	emit_signal("will_push_screen", to_screen)
	bind_screen(to_screen)
	to_screen.will_push_screen()
	screen_history.push_back(to_screen)
	to_screen.grab_focus()

	transition.push_transition(from_screen, to_screen)
	if transition.is_active:
		yield(transition, "transition_completed")

	emit_signal("did_push_screen", to_screen)
	to_screen.did_push_screen()

	if from_screen:
		from_screen.transitioning = true
	to_screen.set_deferred("transitioning", false)

	transitioning = false


func push_initial_screen(screen: UIScreen):
	screen.transitioning = true
	emit_signal("will_push_screen", screen)
	bind_screen(screen)
	screen.will_push_screen()
	screen_history.push_back(screen)
	screen.grab_focus()
	emit_signal("did_push_screen", screen)
	screen.did_push_screen()
	screen.set_deferred("transitioning", false)


func bind_screen(screen: UIScreen):
	for signal_name in CONTROL_SIGNALS:
		if not screen.is_connected(signal_name, self, "_on_control_signal"):
			screen.connect(signal_name, self, "_on_control_signal", [signal_name])


func unbind_screen(screen: UIScreen):
	for signal_name in CONTROL_SIGNALS:
		if screen.is_connected(signal_name, self, "_on_control_signal"):
			screen.disconnect(signal_name, self, "_on_control_signal")


func _on_control_signal(control: Control, signal_name: String):
	emit_signal(signal_name, control)
