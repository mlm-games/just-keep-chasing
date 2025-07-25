class_name BaseProjectile extends Area2D

signal data_changed

var data_resource: ProjectileData:
	set(val):
		data_resource = val
		if is_inside_tree():
			data_changed.emit()

var attack := Attack.new()
var travelled_distance := 0.0
var direction: Vector2
var _pierced_enemies: int = 0
var _rand_spread: float
var _is_active: bool = false

@onready var lifespan_timer: Timer = %LifespanTimer
@onready var light: PointLight2D = %Light

func _ready() -> void:
	set_physics_process(false) # Start disabled
	area_entered.connect(_on_area_entered)

func _on_spawned_from_pool() -> void:
	_is_active = true
	travelled_distance = 0.0
	_pierced_enemies = 0
	#_rand_spread = deg_to_rad(randf_range(-data_resource.projectile_spread, data_resource.projectile_spread))
	
	scale = Vector2.ONE
	modulate.a = 1.0
	
	_on_data_changed()
	
	lifespan_timer.start()
	set_physics_process(true)

func _on_released_to_pool() -> void:
	_is_active = false
	set_physics_process(false)
	
	lifespan_timer.stop()
	
	var tweens = get_tree().get_processed_tweens()
	for tween in tweens:
		if tween.is_valid() and is_ancestor_of(tween.get_bound_node()):
			tween.kill()

func _on_data_changed():
	if not is_inside_tree():
		return
		
	set_collision_mask_value(data_resource.collision_shape_mask, true)
	$Sprite2D.texture = data_resource.sprite_texture
	$Sprite2D.modulate = data_resource.sprite_modulate
	$Sprite2D.scale = data_resource.sprite_scale
	$Sprite2D.offset = data_resource.sprite_offset
	$Sprite2D.rotation_degrees = data_resource.sprite_rotation
	$CollisionShape2D.shape.radius = data_resource.collision_shape_radius
	
	if _is_active:
		VFXSpawner.spawn_particles(data_resource.spawn_particles, global_position, RunData.projectile_root)
	
	lifespan_timer.wait_time = data_resource.lifespan_time
	
	for connection in lifespan_timer.timeout.get_connections():
		lifespan_timer.timeout.disconnect(connection.callable)
	
	lifespan_timer.timeout.connect(_on_lifespan_timeout)

func _on_lifespan_timeout() -> void:
	if _is_active:
		_release_self()

func _physics_process(delta: float) -> void:
	if not _is_active:
		return
		
	var speed_dropoff_mult = data_resource.projectile_speed_dropoff_curve.sample(travelled_distance / data_resource.projectile_range)
	direction = Vector2.RIGHT.rotated(rotation + _rand_spread)
	position += direction * data_resource.projectile_speed * delta * speed_dropoff_mult
	light.energy *= speed_dropoff_mult
	travelled_distance += data_resource.projectile_speed * delta
	
	if travelled_distance > data_resource.projectile_range:
		animate_free()

func _on_area_entered(body: Node2D) -> void:
	if not _is_active or body is not HitboxComponent:
		return
		
	attack.attack_damage = data_resource.projectile_damage
	attack.knockback_force = data_resource.projectile_knockback_force
	attack.stun_duration = data_resource.projectile_stun_duration
	attack.knockback_direction = direction
	
	if not is_zero_approx(data_resource.projectile_dot):
		attack.dot_type = data_resource.projectile_dot_type
		attack.dot_duration = data_resource.projectile_dot_duration
		attack.damage_over_time = data_resource.projectile_dot
		
	body.damage(attack)
	
	_pierced_enemies += 1
	if _pierced_enemies >= data_resource.projectile_max_pierce_count:
		_release_self()

func animate_free(anim_time := 0.1) -> void:
	if not _is_active:
		return
		
	_is_active = false # Prevent further updates
	var consume_tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	consume_tween.tween_property(self, "scale", Vector2.ZERO, anim_time)
	consume_tween.tween_callback(_release_self)

func _release_self() -> void:
	if data_resource and data_resource.base_scene:
		PoolManager.release_to_pool(data_resource.base_scene, self)
