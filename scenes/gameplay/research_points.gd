# Purpose: A collectible research point that uses the 2D physics engine.
class_name ResearchPoint extends RigidBody2D

@export var value: int = 1

# Homing properties
var _target: Node2D = null
var _homing_speed: float = 300.0
var _can_home: bool = false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var pickup_area: Area2D = $PickupArea
@onready var lifetime_timer: Timer = $LifetimeTimer

func _ready():
	lifetime_timer.timeout.connect(queue_free)

# Called when the player enters the outer "pickup" area
func _on_pickup_area_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		_target = body
		_can_home = true
		# Disable gravity so it can fly towards the player
		gravity_scale = 0

# Called when it physically touches the player or another body
func _on_body_entered(body: Node2D):
	if body.is_in_group("Player"):
		# Assuming the player has a method to add points
		if body.has_method("collect_research_points"):
			body.collect_research_points(value)
		
		# Play a collection sound/VFX here
		queue_free()

func _integrate_forces(state: PhysicsDirectBodyState2D):
	if _can_home and is_instance_valid(_target):
		# Apply a force towards the target
		var direction_to_target = (state.transform.origin - _target.global_position).normalized()
		var homing_force = direction_to_target * _homing_speed
		
		# Dampen existing velocity and apply homing force
		state.linear_velocity = state.linear_velocity.lerp(homing_force, 0.1)

# Apply an initial "pop" force when spawned
func pop(initial_force: Vector2):
	apply_central_impulse(initial_force)
