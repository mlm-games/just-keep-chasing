class_name PathfindComponent extends Node

func follow_path(target: CharacterBody2D):
	var direction : Vector2 = get_parent().global_position.direction_to(target.global_position)
		velocity = velocity.lerp(direction * speed, 100 * delta)
	else:
		velocity = direction * speed
	
	update_knock_timer(delta)
	move_and_slide()
