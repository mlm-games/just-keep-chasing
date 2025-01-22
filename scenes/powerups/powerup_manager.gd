extends PickUp

@export var powerup_type: GameState.PowerupType


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_parallel()
		tween.tween_property(self, "global_position", body.global_position, 0.15)
		tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
		await tween.finished
		#TODO: play_audio()
		collect_powerup()
		queue_free()


func collect_powerup() -> void:
	GameState.powerup_collected(powerup_type)
		# Additional powerup collection logic or effects can be added here
