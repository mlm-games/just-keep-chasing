class_name Shotgun extends BaseGun

@export var pellets_per_shot: int 
@export var pellet_spread: float
@export var screen_shake_frequency : float = 10
@export var screen_shake_amplitude : float = 0.5

func spawn_bullet() -> void:
	if ammo > 0:
		for _i in range(pellets_per_shot):
			var bullet_instance = BaseBulletScene.instantiate()
			bullet_instance.set_projectile_values(bullet)
			bullet_instance.global_position = _bullet_spawn_point.global_position
			bullet_instance.global_rotation_degrees = _bullet_spawn_point.global_rotation_degrees + randf_range(-pellet_spread, pellet_spread)
			get_tree().current_scene.add_child(bullet_instance)
		ammo -= 1 
		ScreenEffects.smooth_screen_shake(screen_shake_frequency, screen_shake_amplitude) 
		if ammo == 0:
			reload()
