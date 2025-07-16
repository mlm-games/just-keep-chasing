extends CPUParticles2D

func _ready() -> void:
	self.emitting = true
	await A.tree.create_timer(1).timeout
	queue_free()
