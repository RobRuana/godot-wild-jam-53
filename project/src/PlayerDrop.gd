class_name PlayerDrop
extends RigidBody2D

signal drop_dead
signal clicked

export var speed: float = 10;	
var drop_size: int setget modify_size;
var held = false

func _ready():
	pass
	
func _physics_process(delta):
	if held:
		global_transform.origin = get_global_mouse_position()

func _integrate_forces(state):
	var vel = state.get_linear_velocity();
	if Input.is_action_pressed("move_left"):
		vel.x -= 1 * speed;
	if Input.is_action_pressed("move_right"):
		vel.x += 1 * speed;

	vel += state.get_total_gravity() * state.get_step();
	state.set_linear_velocity(vel);

func on_death():
	# signals the main manager that this player drop is dead
	# and to instantiate a new one
	emit_signal("drop_dead")
	
func modify_size(delta: int):
	# can be used to increase or decrease the drop size
	drop_size += delta;
	if drop_size == 0:
		on_death()

func modify_speed(delta: float):
	speed += delta

func _on_VisibilityNotifier2D_screen_exited():
	on_death()

func _input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			emit_signal("clicked", self)
