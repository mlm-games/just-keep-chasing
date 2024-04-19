extends Area2D

signal collect


func _on_body_entered(body: CharacterBody2D) -> void:
	#TODO: The powerup has a initial velocity to the opposite direction of the player and it then accelerates toward the player upto a limit speed.
	if body.is_in_group("Player"):
		body.powerup_collected()
		body.slow_time_powerup_count += 1
		queue_free()
