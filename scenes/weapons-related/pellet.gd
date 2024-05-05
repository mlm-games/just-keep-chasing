extends Area2D

var pellet_spread := 0.0
@export var speed: float
var travelled_distance := 0.0
var pellet_range := 500
@export var pellet_damage: float
var pellet_attack = Attack.new()
var spread 

func _ready() -> void:
	spread = deg_to_rad(randf_range(-pellet_spread, pellet_spread))
	

func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation + spread)
	position += direction * speed * delta
	travelled_distance += speed * delta
	if travelled_distance > pellet_range:
		queue_free()

func _on_area_entered(body: Node2D) -> void:
	if body is HitboxComponent:
		pellet_attack.attack_damage = pellet_damage
		body.damage(pellet_attack)
	queue_free()
