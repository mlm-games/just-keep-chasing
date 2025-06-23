class_name FollowTargetComponent extends Node

@export var target: Node2D 

func follow_target(velocity_component: VelocityComponent, speed: float):
	if not is_instance_valid(target): return
	
	var direction : Vector2 = (target.global_position - owner.global_position).normalized()
	velocity_component.accelerate_to(direction, speed)
