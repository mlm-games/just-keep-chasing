class_name Projectile1 extends Area2D

@export var speed :float
@export var range := 1000
@export var damage : float
@export var spread : float

var attack := Attack.new()
var travelled_distance := 0.0

@onready var rand_spread = deg_to_rad(randf_range(-spread, spread))


func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation + rand_spread)
	position += direction * speed * delta
	travelled_distance += speed * delta
	if travelled_distance > range:
		queue_free()


func _on_area_entered(body: Node2D) -> void:
	if body is HitboxComponent:
		attack.attack_damage = damage
		body.damage(attack)
	queue_free()
