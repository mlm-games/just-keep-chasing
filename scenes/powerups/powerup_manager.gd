extends Area2D
@export var powerup_type : int

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		collect_powerup(body)
		queue_free()

func collect_powerup(player: Player) -> void:
	player.powerup_collected(powerup_type)
		# Additional powerup collection logic or effects can be added here



