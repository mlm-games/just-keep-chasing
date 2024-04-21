extends Area2D



func _on_body_entered(body: CharacterBody2D) -> void:
	#HACK: The powerup has a initial velocity to the opposite direction of the player and it then accelerates toward the player upto a limit speed.
	if body.is_in_group("Player"):
		GameState.powerup_collected(self.name)
		queue_free()


