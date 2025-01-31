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

func set_shotgun_properties(shotgun_data: ShotgunData) -> void:
	# Apply gun data properties
	if shotgun_data:
		# Set up sprite
		%Sprite2D.texture = shotgun_data.sprite
		%Sprite2D.scale = shotgun_data.sprite_scale
		%Sprite2D.position = shotgun_data.sprite_position
		%Sprite2D.rotation = shotgun_data.sprite_rotation
		%Sprite2D.flip_h = shotgun_data.sprite_flip_h
		
		 # Set up bullet spawn point
		%BulletSpawnPoint.position = shotgun_data.bullet_spawn_offset
		
		 # Set up timers
		_reload_timer.wait_time = shotgun_data.reload_time
		_fire_rate_timer.wait_time = shotgun_data.fire_rate
		
		# Set other properties
		max_ammo = shotgun_data.max_ammo
		ammo = shotgun_data.ammo
		targeting_range = shotgun_data.targeting_range
		pellets_per_shot = shotgun_data.pellets_per_shot
		pellet_spread = shotgun_data.pellet_spread
		screen_shake_amplitude = shotgun_data.screen_shake_amplitude
		screen_shake_frequency = shotgun_data.screen_shake_frequency
