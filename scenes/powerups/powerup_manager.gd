extends PickUp



@export var powerup_type: GameState.PowerupType


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		collect_powerup()
		queue_free()


func collect_powerup() -> void:
	GameState.powerup_collected(powerup_type)
		# Additional powerup collection logic or effects can be added here
