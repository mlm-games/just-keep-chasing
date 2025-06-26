class_name PlayerInputComponent extends Node

## Reads player input (keyboard/joystick) and emits a normalized direction vector.
## It doesn't move anything itself, it only provides input data.


@onready var move_joy = get_tree().get_first_node_in_group("MovementJoystick")
@onready var shoot_joy = get_tree().get_first_node_in_group("ShootingJoystick")

signal direction_changed(direction: Vector2)

var movement_joystick_direction : Vector2

func _ready():
	move_joy.direction_changed.connect(on_move_direction_changed)
	shoot_joy.direction_changed.connect(on_shoot_direction_changed)

func on_move_direction_changed(direction: Vector2):
	movement_joystick_direction = direction

func on_shoot_direction_changed(direction: Vector2):
	pass #TODO: later

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Override with joystick input if it's being used
	if movement_joystick_direction != Vector2.ZERO:
		direction = movement_joystick_direction
	
	direction_changed.emit(direction)
