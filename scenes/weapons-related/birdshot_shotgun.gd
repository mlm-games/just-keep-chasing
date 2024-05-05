class_name BirdshotShotgun extends Shotgun

func spawn_bullet() -> void:
	if ammo > 0:
		for _i in range(pellets_per_shot):
			var pellet_instance = bullet.scene.instantiate()
			pellet_instance.global_position = _bullet_spawn_point.global_position
			pellet_instance.global_rotation_degrees = _bullet_spawn_point.global_rotation_degrees + randf_range(-pellet_spread, pellet_spread)
			get_tree().current_scene.add_child(pellet_instance)
		ammo -= 1  
		if ammo < 1:
			reload()

