class_name FireBullet extends BaseProjectile

#@export var damage_over_time: float
#@export var dot_duration: float
#
#func _physics_process(delta: float) -> void:
	#var direction = Vector2.RIGHT.rotated(rotation)
	#position += direction * speed * delta
	#travelled_distance += speed * delta
	#if travelled_distance > bullet_range:
		#queue_free()
#
#
#func _on_area_entered(body: Node2D) -> void:
	#if body is HitboxComponent:
		#bullet_attack.attack_damage = bullet_damage
		#bullet_attack.damage_over_time = damage_over_time
		#bullet_attack.dot_duration = dot_duration
		#body.damage(bullet_attack)
		#body.dot(damage_over_time, 3)
	#queue_free()
