extends Node2D


signal queue_freed


onready var screen_size: = get_viewport_rect().size
var queue_free_count: int = 0

var game
var player


func _init():
	pause_mode = PAUSE_MODE_PROCESS


func _ready():
	randomize()


func instance(source, properties: Dictionary = {}) -> Node:
	var resource = ResourceLoader.load(source) if source is String else source
	var obj
	if resource.can_instance():
		if resource is PackedScene:
			obj = resource.instance()
		elif resource is GDScript:
			obj = resource.new()

	if obj:
		if properties:
			for name in properties:
				obj.set(name, properties[name])
	else:
		push_error("Unable to instance: %s" % source)

	return obj


func is_focusable(node: Node) -> bool:
	return node is Control and node.focus_mode != Control.FOCUS_NONE


func get_focusable_controls(parent_node: Node) -> Array:
	var nodes: Array = []
	if is_focusable(parent_node):
		nodes.append(parent_node)
	for node in parent_node.get_children():
		nodes.append_array(get_focusable_controls(node))
	return nodes


func get_last_child(parent_node: Node, index: int = -1):
	var child_count: int = parent_node.get_child_count()
	if int(abs(index)) <= child_count:
		return parent_node.get_child(index + child_count)
	return null


func get_screen_center(node: CanvasItem) -> Vector2:
	var transform: Transform2D = node.get_viewport_transform()
	var scale: Vector2 = transform.get_scale()
	return -(transform.origin / scale) + ((node.get_viewport_rect().size / scale) * 0.5)


func nodes_are_friendly(source: Node, target: Node) -> bool:
	return (
		nodes_share_any_groups(source, target, ["enemy", "player"])
		or (
			source.is_in_group("friend") and target.is_in_group("player")
		)
	)


func nodes_share_any_groups(n1: Node, n2: Node, groups: Array) -> bool:
	if n1 and n2:
		for group in groups:
			if n1.is_in_group(group) and n2.is_in_group(group):
				return true
	return false


func call_delayed(obj: Object, method: String, delay: float, args: Array = []):
	yield(get_tree().create_timer(delay), "timeout")
	if is_instance_valid(obj):
		obj.callv(method, args)


func safe_queue_free_remove_child(parent: Node, child: Node, delay: float = -1.0):
	queue_free_count += 1
	if delay > 0.0:
		yield(get_tree().create_timer(delay), "timeout")
	if is_instance_valid(parent) and is_instance_valid(child):
		if parent == child.get_parent():
			parent.remove_child(child)
		child.queue_free()
	queue_free_count -= 1
	if queue_free_count == 0:
		emit_signal("queue_freed")


func safe_reload_current_scene(timeout: float = -1.0):
	if queue_free_count > 0:
		if timeout < 0.0:
			yield(self, "queue_freed")
		elif timeout > 0.0:
			var elapsed: float = 0.0
			while queue_free_count > 0 and elapsed < timeout:
				yield(get_tree().create_timer(0.1), "timeout")
				elapsed += 0.1

	Events.reset_once()
	get_tree().reload_current_scene()


func set_node_disabled(node: Node, disabled: bool):
	if disabled:
		node.set_process(false)
		node.set_process_input(false)
		node.set_process_unhandled_input(false)
		node.set_process_unhandled_key_input(false)
		node.set_physics_process(false)
	else:
		if node.has_method("_process"):
			node.set_process(true)
		if node.has_method("_input"):
			node.set_process_input(true)
		if node.has_method("_unhandled_input"):
			node.set_process_unhandled_input(true)
		if node.has_method("_unhandled_key_input"):
			node.set_process_unhandled_key_input(true)
		if node.has_method("_physics_process"):
			node.set_physics_process(true)


func time_scale(scale: float = 1.0, duration: float = 1.0, delay: float = 0.0):
	if delay > 0.0:
		yield(get_tree().create_timer(Engine.time_scale * delay), "timeout")
	Engine.time_scale *= scale

	yield(get_tree().create_timer(Engine.time_scale * duration), "timeout")

	var reverted_scale: float = Engine.time_scale / scale
	if is_equal_approx(reverted_scale, 1.0):
		Engine.time_scale = 1.0
	else:
		Engine.time_scale = reverted_scale
