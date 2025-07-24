class_name FlakCanister extends BaseProjectile

@export var shrapnel_scene: PackedScene  
@export var shrapnel_count: int = 8
@export var shrapnel_spread_degrees: float = 45.0
@export var detonation_distance: float = 400.0

func _physics_process(delta: float):
	super._physics_process(delta)
	
	if travelled_distance >= detonation_distance:
		detonate()
		PoolManager.get_pool(projectile_data.base_scene).release_object(self)

func detonate():
	var base_angle = global_rotation
	var spread_rads = deg_to_rad(shrapnel_spread_degrees)
	
	for i in shrapnel_count:
		var shrapnel = shrapnel_scene.instantiate()
		RunData.projectile_root.add_child(shrapnel)
		shrapnel.global_position = global_position
		var random_angle = randf_range(-spread_rads / 2.0, spread_rads / 2.0)
		shrapnel.global_rotation = base_angle + random_angle
