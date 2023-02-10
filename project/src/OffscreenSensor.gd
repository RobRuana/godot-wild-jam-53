class_name OffscreenSensor
extends VisibilityNotifier2D


signal onscreen(entity)
signal offscreen(entity)


export var autosize: bool = true
export var autoremove_entity: bool = false
export var onscreen_grace_period: float = 0.0
export var offscreen_grace_period: float = 1.0
var onscreen_timer: Timer
var offscreen_timer: Timer


func _ready():
	offscreen_timer = get_node_or_null("OffscreenTimer")
	if not offscreen_timer:
		offscreen_timer = Timer.new()
		offscreen_timer.name = "OffscreenTimer"
		offscreen_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
		offscreen_timer.one_shot = true
		offscreen_timer.autostart = false
		add_child(offscreen_timer)

	onscreen_timer = get_node_or_null("OnscreenTimer")
	if not onscreen_timer:
		onscreen_timer = Timer.new()
		onscreen_timer.name = "OnscreenTimer"
		onscreen_timer.process_mode = Timer.TIMER_PROCESS_PHYSICS
		onscreen_timer.one_shot = true
		onscreen_timer.autostart = false
		add_child(onscreen_timer)

	call_deferred("initialize", get_parent())


func initialize(entity: Node2D):
	if autosize:
		if entity.has_method("get_rect"):
			self.rect = entity.get_rect()
		if entity.has_method("get_center"):
			self.position = entity.get_center()
		else:
			self.position = self.rect.get_center()

	if not is_connected("screen_entered", self, "_on_screen_entered"):
		connect("screen_entered", self, "_on_screen_entered", [entity])
	if not offscreen_timer.is_connected("timeout", self, "_on_offscreen_timeout"):
		offscreen_timer.connect("timeout", self, "_on_offscreen_timeout", [entity])
	if not onscreen_timer.is_connected("timeout", self, "_on_onscreen_timeout"):
		onscreen_timer.connect("timeout", self, "_on_onscreen_timeout", [entity])


func component_unregistered(entity: Node2D):
	if is_connected("screen_entered", self, "_on_screen_entered"):
		disconnect("screen_entered", self, "_on_screen_entered")
	if is_connected("screen_exited", self, "_on_screen_exited"):
		disconnect("screen_exited", self, "_on_screen_exited")


func _on_screen_entered(entity: Node2D):
	if not is_connected("screen_exited", self, "_on_screen_exited"):
		connect("screen_exited", self, "_on_screen_exited", [entity])
	offscreen_timer.stop()
	if onscreen_grace_period > 0.0:
		# The screen_entered event can fire as the entity is being removed from the scene
		if onscreen_timer.is_inside_tree():
			onscreen_timer.start(onscreen_grace_period)
	else:
		_on_onscreen_timeout(entity)


func _on_screen_exited(entity: Node2D):
	onscreen_timer.stop()
	if offscreen_grace_period > 0.0:
		# The screen_exited event can fire as the entity is being removed from the scene
		if offscreen_timer.is_inside_tree():
			offscreen_timer.start(offscreen_grace_period)
	else:
		_on_offscreen_timeout(entity)


func _on_onscreen_timeout(entity: Node2D):
	emit_signal("onscreen", entity)
	Events.emit_signal("onscreen", entity)


func _on_offscreen_timeout(entity: Node2D):
	emit_signal("offscreen", entity)
	Events.emit_signal("offscreen", entity)
	if autoremove_entity:
		# Need to call_deferred() to prevent error
		# E 0:00:13.680   _exit_viewport: Condition "!viewports.has(p_viewport)" is true.
		# <C++ Source>  scene/2d/visibility_notifier_2d.cpp:68 @ _exit_viewport()
		entity.call_deferred("queue_free")
