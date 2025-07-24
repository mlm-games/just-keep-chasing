class_name ZigZagProjectile extends BaseProjectile

@export var wave_frequency: float = 10.0 # How fast it wiggles
@export var wave_amplitude: float = 50.0  # How wide it wiggles

var _time: float = 0.0

func _physics_process(delta: float):
	_time += delta
	var forward_direction = Vector2.RIGHT.rotated(global_rotation)
	var sideways_direction = forward_direction.orthogonal()
	
	var forward_movement = forward_direction * projectile_data.projectile_speed * delta
	var sideways_movement = sideways_direction * sin(_time * wave_frequency) * wave_amplitude * delta
	
	position += forward_movement + sideways_movement
	
	travelled_distance += projectile_data.projectile_speed * delta
	if travelled_distance > projectile_data.projectile_range:
		PoolManager.get_pool(projectile_data.base_scene).release_object(self)
