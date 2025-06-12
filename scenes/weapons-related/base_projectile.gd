class_name BaseProjectile extends Area2D

const BaseScene = preload("uid://b5x54mjk1mls0")
const SpawnParticles = preload("uid://rhergnlmde1y")

@export var speed : float
@export var projectile_range := 1000
@export var damage : float
@export var spread : float
@export var dot : float = NAN
@export var dot_type : GameState.StatusEffectType
@export var dot_duration : float = NAN

var projectile_data: ProjectileData

var attack := Attack.new()
var travelled_distance := 0.0
var direction : Vector2

@onready var _rand_spread : float = deg_to_rad(randf_range(-projectile_data.projectile_spread, projectile_data.projectile_spread))

static func new_instance(data: ProjectileData) -> BaseProjectile:
	var instance : BaseProjectile = BaseScene.instantiate()
	instance.projectile_data = data
	return instance


func _ready() -> void:
	set_collision_mask_value(projectile_data.collision_shape_mask, true)
	$Sprite2D.texture = projectile_data.sprite_texture
	$Sprite2D.modulate = projectile_data.sprite_modulate
	$Sprite2D.scale = projectile_data.sprite_scale
	$Sprite2D.offset = projectile_data.sprite_offset
	$Sprite2D.rotation_degrees = projectile_data.sprite_rotation
	$CollisionShape2D.shape.radius = projectile_data.collision_shape_radius
	add_child(SpawnParticles.instantiate())

func _physics_process(delta: float) -> void:
	direction = Vector2.RIGHT.rotated(rotation + _rand_spread)
	position += direction * projectile_data.projectile_speed * delta
	travelled_distance += projectile_data.projectile_speed * delta
	if travelled_distance > projectile_data.projectile_range:
		queue_free()


func _on_area_entered(body: Node2D) -> void:
	if body is HitboxComponent:
		attack.attack_damage = projectile_data.projectile_damage
		
		body.apply_knockback(direction, 10, 0.2)
		if not is_nan(dot):
			attack.dot_type = dot_type
			attack.dot_duration = dot_duration
			attack.damage_over_time = dot
		body.damage(attack)
	queue_free()
