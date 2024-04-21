extends Area2D

@export var speed :float
var travelled_distance := 0.0
var bullet_range := 1000
@export var bullet_damage :float
var bullet_attack = Attack.new()

func _physics_process(delta: float) -> void:
	var direction = Vector2.RIGHT.rotated(rotation)
	position += direction * speed * delta
	travelled_distance += speed * delta
	if travelled_distance > bullet_range:
		queue_free()


func _on_area_entered(body: Node2D) -> void:
	if body is HitboxComponent:
		bullet_attack.attack_damage = bullet_damage
		body.damage(bullet_attack)
	queue_free()
