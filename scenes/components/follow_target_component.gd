class_name FollowTargetComponent extends Node

## It will be driven by the state chart.
@export var target: Node2D

## This is the function the "Chase" state will call.
func follow_target(velocity_component: VelocityComponent):
	if not is_instance_valid(target): return
	
	var direction : Vector2 = (target.global_position - owner.global_position).normalized()
	velocity_component.accelerate_to(direction)
