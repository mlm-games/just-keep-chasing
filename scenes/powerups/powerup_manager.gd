extends Area2D
@export var powerup_type : String 

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		body.powerup_collected(powerup_type)
		queue_free()


