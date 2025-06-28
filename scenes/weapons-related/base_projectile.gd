class_name BaseProjectile extends Area2D

var projectile_data: ProjectileData

var attack := Attack.new()
var travelled_distance := 0.0
var direction : Vector2

var _pierced_enemies: int = 0


@onready var _rand_spread : float = deg_to_rad(randf_range(-projectile_data.projectile_spread, projectile_data.projectile_spread))
@onready var lifespan_timer: Timer = %LifespanTimer

static func new_instance(data: ProjectileData) -> BaseProjectile:
	var instance : BaseProjectile = data.base_scene.instantiate()
	instance.projectile_data = data
	return instance


func _ready() -> void:
	
	area_entered.connect(_on_area_entered.bind())
	
	set_collision_mask_value(projectile_data.collision_shape_mask, true)
	$Sprite2D.texture = projectile_data.sprite_texture
	$Sprite2D.modulate = projectile_data.sprite_modulate
	$Sprite2D.scale = projectile_data.sprite_scale
	$Sprite2D.offset = projectile_data.sprite_offset
	$Sprite2D.rotation_degrees = projectile_data.sprite_rotation
	$CollisionShape2D.shape.radius = projectile_data.collision_shape_radius
	
	VFXSpawner.spawn_particles(projectile_data.spawn_particles, global_position, RunData.projectile_root)
	
	lifespan_timer.wait_time = projectile_data.lifespan_time
	lifespan_timer.timeout.connect(queue_free)
	


func _physics_process(delta: float) -> void:
	direction = Vector2.RIGHT.rotated(rotation + _rand_spread)
	position += direction * projectile_data.projectile_speed * delta
	travelled_distance += projectile_data.projectile_speed * delta
	if travelled_distance > projectile_data.projectile_range:
		queue_free()


func _on_area_entered(body: Node2D) -> void:
	if body is HitboxComponent:
		attack.attack_damage = projectile_data.projectile_damage
		attack.knockback_force = projectile_data.projectile_knockback_force
		attack.stun_duration = projectile_data.projectile_stun_duration
		attack.knockback_direction = direction
		
		body.apply_knockback(direction, 10, 0.2)
		if not is_zero_approx(projectile_data.projectile_dot):
			attack.dot_type = projectile_data.projectile_dot_type
			attack.dot_duration = projectile_data.projectile_dot_duration
			attack.damage_over_time = projectile_data.projectile_dot
		body.damage(attack)
		
		_pierced_enemies += 1
		if _pierced_enemies >= projectile_data.projectile_max_pierce_count:
			queue_free()
