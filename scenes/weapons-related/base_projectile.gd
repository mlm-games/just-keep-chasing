class_name BaseProjectile extends Area2D

var projectile_data: ProjectileData

var travelled_distance := 0.0
var direction: Vector2

var _pierced_enemies: int = 0
var _rand_spread: float

@onready var lifespan_timer: Timer = %LifespanTimer
@onready var light: PointLight2D = %Light
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	if not projectile_data:
		push_error("BaseProjectile: Missing projectile_data!")
		queue_free()
		return
	
	_rand_spread = deg_to_rad(randf_range(-projectile_data.projectile_spread, projectile_data.projectile_spread))
	
	area_entered.connect(_on_area_entered)
	
	# Set collision mask
	collision_mask = 0
	set_collision_mask_value(projectile_data.collision_shape_mask, true)
	
	# Setup sprite
	if not projectile_data.sprite_texture:
		push_error("BaseProjectile: projectile_data.sprite_texture is null")
	else:
		sprite.texture = projectile_data.sprite_texture
	sprite.modulate = projectile_data.sprite_modulate
	sprite.scale = projectile_data.sprite_scale
	sprite.offset = projectile_data.sprite_offset
	sprite.rotation_degrees = projectile_data.sprite_rotation
	
	# Setup collision
	collision_shape.shape.radius = projectile_data.collision_shape_radius
	
	# Spawn particles
	if projectile_data.spawn_particles:
		VFXSpawner.spawn_particles(projectile_data.spawn_particles, global_position, RunData.projectile_root)
	
	# Setup lifespan timer
	lifespan_timer.wait_time = projectile_data.lifespan_time
	lifespan_timer.timeout.connect(_on_lifespan_timeout)
	lifespan_timer.start()


func _physics_process(delta: float) -> void:
	if not projectile_data:
		return
	
	var speed_dropoff_mult := 1.0
	if projectile_data.projectile_speed_dropoff_curve:
		var progress = travelled_distance / projectile_data.projectile_range
		speed_dropoff_mult = projectile_data.projectile_speed_dropoff_curve.sample(clampf(progress, 0.0, 1.0))
	
	direction = Vector2.RIGHT.rotated(rotation + _rand_spread)
	var movement = direction * projectile_data.projectile_speed * delta * speed_dropoff_mult
	position += movement
	
	if light:
		light.energy *= speed_dropoff_mult
	
	travelled_distance += movement.length()
	
	if travelled_distance > projectile_data.projectile_range:
		animate_free()


func _on_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		var attack := Attack.new()
		attack.attack_damage = projectile_data.projectile_damage
		attack.knockback_force = projectile_data.projectile_knockback_force
		attack.stun_duration = projectile_data.projectile_stun_duration
		attack.knockback_direction = direction
		
		if not is_zero_approx(projectile_data.projectile_dot):
			attack.dot_type = projectile_data.projectile_dot_type
			attack.dot_duration = projectile_data.projectile_dot_duration
			attack.damage_over_time = projectile_data.projectile_dot
		
		area.damage(attack)
		
		_pierced_enemies += 1
		if _pierced_enemies >= projectile_data.projectile_max_pierce_count:
			queue_free()


func _on_lifespan_timeout() -> void:
	queue_free()


func animate_free(anim_time: float = 0.1) -> void:
	set_physics_process(false)
	var consume_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	consume_tween.tween_property(self, "scale", Vector2.ZERO, anim_time)
	consume_tween.tween_callback(queue_free)
