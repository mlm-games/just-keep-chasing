extends CharacterBody2D
#FIXME: While dying, if the enemy also dies, causes an error, but dont know hwat happens if u continue instead of quitting
func _physics_process(_delta: float) -> void:
	move_and_slide()
