
tool
class_name ViewportCanvasLayer
extends CanvasLayer


export var _target_viewport: NodePath setget set_target_viewport

func set_target_viewport(value: NodePath):
	_target_viewport = value

	if is_inside_tree():
		custom_viewport = Global.get_node_for_path(self, _target_viewport)
		has_viewport = (custom_viewport != null and custom_viewport is Viewport)



var has_viewport: bool = false


func _ready():
	set_target_viewport(_target_viewport)
	_reposition()


func _physics_process(delta: float) -> void:
	_reposition()


func _reposition():
	if Engine.editor_hint and has_viewport:
		var viewport_extents: Vector2 = custom_viewport.size * 0.5
		self.transform = Transform2D.IDENTITY
		for view in get_children():
			view.global_position = viewport_extents
	else:
		var parent: CanvasItem = get_parent()
		var parent_origin: Vector2 = parent.get_global_transform().origin
		var parent_canvas_origin: Vector2 = parent.get_global_transform_with_canvas().origin
		self.transform = Transform2D(
			transform.x,
			transform.y,
			parent_canvas_origin - parent_origin
		)
		for view in get_children():
			if view is Control:
				view.rect_global_position = parent_origin
			else:
				view.global_position = parent_origin
