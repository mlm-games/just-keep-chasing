class_name Shotgun extends BaseGun

@export var pellets_per_shot: int 
@export var pellet_spread: float
@export var screen_shake_frequency : float = 10
@export var screen_shake_amplitude : float = 0.5

func spawn_bullet() -> void:
	if ammo > 0:
		for _i in range(pellets_per_shot):
			var bullet_instance: BaseProjectile = BaseBulletScene.instantiate()
			bullet_instance.projectile_data = gun_data.bullet
			bullet_instance.global_position = _bullet_spawn_point.global_position
			bullet_instance.global_rotation_degrees = _bullet_spawn_point.global_rotation_degrees + randf_range(-pellet_spread, pellet_spread)
			get_tree().current_scene.add_child(bullet_instance)
		ammo -= 1 
		ScreenEffects.smooth_screen_shake(screen_shake_frequency, screen_shake_amplitude) 
		if ammo == 0:
			reload()

func set_gun_properties(local_gun_data: GunData) -> void:
	# Apply gun data properties
	super.set_gun_properties(local_gun_data)
	pellets_per_shot = local_gun_data.pellets_per_shot
	pellet_spread = local_gun_data.pellet_spread
	screen_shake_amplitude = local_gun_data.screen_shake_amplitude
	screen_shake_frequency = local_gun_data.screen_shake_frequency
