class_name SniperProjectile extends BaseProjectile

var _pierced_enemies: int = 0

func _on_area_entered(body: Node2D) -> void:
	if body is HitboxComponent:
		attack.attack_damage = projectile_data.projectile_damage
		body.damage(attack)
		
		_pierced_enemies += 1
		if _pierced_enemies >= projectile_data.projectile_max_pierce_count:
			queue_free() # Destroy bullet after hitting enough enemies
