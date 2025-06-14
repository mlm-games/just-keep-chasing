class_name PlayerInputComponent extends Node

## Reads player input (keyboard/joystick) and emits a normalized direction vector.
## It doesn't move anything itself, it only provides input data.

signal direction_changed(direction: Vector2)

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	# Override with joystick input if it's being used
	if GameState.movement_joystick_direction != Vector2.ZERO:
		direction = GameState.movement_joystick_direction
	
	direction_changed.emit(direction)
