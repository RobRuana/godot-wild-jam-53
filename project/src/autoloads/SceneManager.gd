extends CanvasLayer


signal root_scene_changing
signal root_scene_changed


var controller_history: Array = []
var is_active: bool = false


func _init():
	pause_mode = PAUSE_MODE_PROCESS
	layer = 120


func change_root_scene(path: String):
	if is_active:
		return
	is_active = true

	if get_tree().current_scene:
		GlobalOverlay.fade_to_black()

	var packed_scene: PackedScene
	if OS.get_name() == "HTML5":
		if GlobalOverlay.is_active:
			yield(GlobalOverlay, "fade_all_completed")
		packed_scene = ResourceLoader.load(path)
	else:
		packed_scene = yield(ResourceQueue.load_async(path), "completed")
		if GlobalOverlay.is_active:
			yield(GlobalOverlay, "fade_all_completed")

	for controller in controller_history:
		if is_instance_valid(controller):
			controller.queue_free()
	controller_history.clear()
	Events.reset_once()

	emit_signal("root_scene_changing")
	get_tree().change_scene_to(packed_scene)
	get_tree().paused = false
	emit_signal("root_scene_changed")

	yield(GlobalOverlay.fade_to_transparent(), "completed")
	GlobalOverlay.remove_content()
	is_active = false


func push_controller(scene: PackedScene):
	var controller = scene.instance()
	controller.visible = false
	add_child(controller)
	controller_history.push_back(controller)
	controller.connect("pop_controller_requested", self, "pop_controller", [], CONNECT_ONESHOT)
	yield(controller.fader.fade_to_opaque(controller), "completed")
	return controller


func pop_controller(controller):
	yield(controller.fader.fade_to_transparent(controller), "completed")
	if is_instance_valid(controller):
		controller_history.erase(controller)
		controller.queue_free()
		controller.emit_signal("pop_controller_completed", controller)
