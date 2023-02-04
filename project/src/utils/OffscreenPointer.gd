class_name OffscreenPointer
extends Node2D


export var color: Color = Color.white setget set_color
export var margin: float = 64.0
export var is_offscreen: bool = false
export var target_path: NodePath setget set_target_path
var target: Node2D


func set_color(value: Color):
	$Arrow.color = value


func set_target_path(value: NodePath):
	target_path = value
	if has_node(value):
		target = get_node(value)
		set_process(true)
	else:
		set_process(false)


func _ready():
	if not target_path:
		self.target_path = ".."
	Events.connect("game_reset", self, "_on_game_reset")


func _on_game_reset():
	$Fader.fade_to_transparent(self, 0.0)


func _process(delta: float):
	if Engine.editor_hint or Global.game.state != Const.GameState.PLAYING:
		return

	var screen_center: = Global.get_screen_center(self)
	var screen_size: = get_viewport_rect().size
	var screen_extents: = screen_size * 0.5
	var screen_rect: = Rect2(screen_center - screen_extents, screen_size)
	if Math.is_circle_outside_rect(target.global_position, target.radius, screen_rect):
		var boundry: = screen_rect.grow_individual(-margin, -margin, -margin, -margin)
		var intersection = Math.segment_intersects_rect(screen_center, target.global_position, boundry)
		if intersection:
			self.global_position = intersection
			self.rotation = target.global_position.angle_to_point(screen_center)
			if not self.is_offscreen:
				self.is_offscreen = true
				$Fader.fade_to_opaque(self)
	elif self.is_offscreen:
		self.is_offscreen = false
		$Fader.fade_to_transparent(self)
