extends Area2D


func _on_body_entered(body: CharacterBody2D) -> void:
	#TODO: The powerup has a initial velocity to the opposite direction of the player and it then accelerates toward the player upto a limit speed.
	if body.is_in_group("Player"):
		body.powerup_collected()
		GameState.screen_blast_powerup_count += 1
		queue_free()
#TODO: the powerup will be affected by the name of the powerup which will also be sent to the player to call that powerup
