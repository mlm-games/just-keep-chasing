class_name BaseProjectile extends Area2D

@export var speed :float
@export var projectile_range := 1000
@export var damage : float
@export var spread : float
@export var dot : float = NAN
@export var dot_type : GameState.StatusEffectType
@export var dot_duration : float = NAN

var projectile_data: ProjectileData

var attack := Attack.new()
var travelled_distance := 0.0

@onready var _rand_spread = deg_to_rad(randf_range(-spread, spread))

func _ready() -> void:
	set_projectile_values(projectile_data)

func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation + _rand_spread)
	position += direction * speed * delta
	travelled_distance += speed * delta
	if travelled_distance > projectile_range:
		queue_free()


func _on_area_entered(body: Node2D) -> void:
	if body is HitboxComponent:
		attack.attack_damage = damage
		if not is_nan(dot):
			attack.dot_type = dot_type
			attack.dot_duration = dot_duration
			attack.damage_over_time = dot
		body.damage(attack)
	queue_free()


func set_projectile_values(projectile_data: ProjectileData):
	$CollisionShape2D.shape.radius = projectile_data.collision_shape_radius
	set_collision_mask_value(projectile_data.collision_shape_mask, true)
	damage = projectile_data.projectile_damage
	projectile_range = projectile_data.projectile_range
	speed = projectile_data.projectile_speed
	spread = projectile_data.projectile_spread
	$Sprite2D.texture = projectile_data.sprite_texture
	$Sprite2D.modulate = projectile_data.sprite_modulate
	$Sprite2D.scale = projectile_data.sprite_scale
	$Sprite2D.offset = projectile_data.sprite_offset
	$Sprite2D.rotation_degrees = projectile_data.sprite_rotation
