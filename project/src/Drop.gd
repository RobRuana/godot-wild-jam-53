class_name Drop
extends KinematicBody2D

signal drop_dead

var fall_factor: float setget set_fall_factor
export var size: float setget set_size
var pressed: bool = false
var hovered: bool
var mouse_pos: Vector2
# keep some randomness in how rain drops are falling
var velocity: Vector2
var scale_factor: float = 0.5

func get_class(): return "Drop"

func _ready():
	hovered = false
	set_process_input(true)
	velocity.x = 0
	velocity.y = 1
	set_size(rand_range(2,5))
	set_fall_factor(10)

func drop_dead():
	emit_signal("drop_dead")
	queue_free()

func set_fall_factor(factor: float):
	fall_factor = factor

func set_size(_size: float):
	size = _size
	update_scale()

func update_scale():
	var new_scale = size * scale_factor;
	scale = Vector2(0.75 * new_scale, new_scale)

func _process(delta):
	if pressed:
		position = mouse_pos
	else:
		pass

func _physics_process(delta):
	# update the position of the drop over time
	var collision = move_and_collide(velocity * delta * size * fall_factor)
	# if we collided due to the player movement, handle differently
	# than if we collided due to random chance
	if collision:
		if pressed:
			var col = collision.collider
			if col.get_class() == "Drop":
				set_size((size + col.size) * 0.8)
				col.drop_dead()
				# toggle the controls off for this drop
				pressed = false

func _unhandled_input(event):
	if pressed and event is InputEventMouseMotion:
		mouse_pos = event.position
	elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT and not event.pressed:
		pressed = false
	elif hovered:
		if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
			pressed = event.pressed
			mouse_pos = event.position

func _on_Drop_mouse_entered():
	hovered = true

func _on_Drop_mouse_exited():
	hovered = false

func _on_VisibilityNotifier2D_viewport_exited(viewport):
	drop_dead()
