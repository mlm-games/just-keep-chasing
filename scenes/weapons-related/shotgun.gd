class_name Shotgun extends BaseWeapon

@export var pellets_per_shot: int 
@export var pellet_spread: float


func spawn_bullet() -> void:
	if ammo > 0:
		for _i in range(pellets_per_shot):
			var pellet_instance = bullet.scene.instantiate()
			pellet_instance.global_position = _bullet_spawn_point.global_position
			pellet_instance.global_rotation_degrees = _bullet_spawn_point.global_rotation_degrees + randf_range(-pellet_spread, pellet_spread)
			get_tree().current_scene.add_child(pellet_instance)
		ammo -= 1 
		Utils.screen_shake(0.1,0.5,get_viewport().get_camera_2d()) 
		if ammo == 0:
			reload()

