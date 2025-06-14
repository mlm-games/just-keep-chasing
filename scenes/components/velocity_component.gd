class_name VelocityComponent extends Node

## Manages velocity, speed, and knockback for a CharacterBody2D parent.
## This component handles the actual movement call (move_and_slide).

## The maximum speed of the character.
@export var speed: float = 100.0

## The current velocity of the character. Read-only for other nodes.
var velocity: Vector2

# Private variables for knockback
var _knockback_vector := Vector2.ZERO
var _knockback_timer := 0.0
var _is_knocked_back := false


func _physics_process(delta: float) -> void:
	var body: CharacterBody2D = get_parent() as CharacterBody2D
	if not body:
		printerr("VelocityComponent's parent is not a CharacterBody2D. Disabling component.")
		set_physics_process(false)
		return

	# Handle knockback timer and state
	if _is_knocked_back:
		_knockback_timer -= delta
		if _knockback_timer <= 0.0:
			_is_knocked_back = false
			velocity = Vector2.ZERO # Reset velocity after knockback
		else:
			# Apply knockback velocity
			body.velocity = _knockback_vector
			body.move_and_slide()
			# Update our public velocity property for other nodes to read
			self.velocity = body.velocity 
			return # Skip normal movement during knockback

	# Apply normal velocity
	body.velocity = velocity
	body.move_and_slide()
	# Update our public velocity property with the result of the slide (for collision response)
	self.velocity = body.velocity


## Sets the velocity based on a direction vector and the component's speed.
func accelerate_in_direction(direction: Vector2) -> void:
	# Don't accept movement input during knockback
	if _is_knocked_back:
		return
		
	velocity = direction.normalized() * speed


## Applies an instant force, pushing the character back.
func apply_knockback(force: Vector2, duration: float = 0.2) -> void:
	_knockback_vector = force
	_knockback_timer = duration
	_is_knocked_back = true
