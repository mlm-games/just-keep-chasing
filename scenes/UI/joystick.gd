## A self-contained, reusable virtual joystick component.
## It handles its own touch input and visibility, and emits its output.
class_name VirtualJoystick extends Control

signal direction_changed(direction: Vector2)
signal released

@onready var outer_ring: TextureRect = %Outer
@onready var inner_stick: TextureRect = %Inner

## The max distance the stick can move.
@export var boundary: float = 75.0 

var _touch_index: int = -1 # The finger ID currently controlling this joystick
var _start_position: Vector2

func _ready():
	# Start hidden and only appear on touch
	hide()

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.is_pressed():
			# If no finger is controlling this joystick yet, claim this one.
			if _touch_index == -1:
				_start_position = event.position
				global_position = _start_position - (size / 2) # Center the joystick on the touch point
				show()
				_touch_index = event.index
				_update_stick_position(event.position)
		elif event.is_released():
			# If the finger being released is the one controlling this joystick
			if event.index == _touch_index:
				_reset()

	elif event is InputEventScreenDrag:
		# If the finger being dragged is the one controlling this joystick
		if event.index == _touch_index:
			_update_stick_position(event.position)

func _update_stick_position(current_pos: Vector2):
	var direction_vector = current_pos - _start_position
	var distance = direction_vector.length()
	
	# Clamp the inner stick's movement within the boundary
	if distance > boundary:
		inner_stick.position = direction_vector.normalized() * boundary
	else:
		inner_stick.position = direction_vector
	
	# Emit the normalized direction
	emit_signal("direction_changed", direction_vector.normalized())

func _reset():
	GameState.movement_joystick_direction = Vector2.ZERO
	_touch_index = -1
	inner_stick.position = Vector2.ZERO
	hide()
	emit_signal("released")
	emit_signal("direction_changed", Vector2.ZERO)
