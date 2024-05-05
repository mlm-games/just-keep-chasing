#hack: update health bar in hud

class_name HealthComponent extends Node2D

signal player_died
signal taking_damage
signal health_changed(new_health)

@export var max_health: float 
var current_health: float

func _ready() -> void:
	current_health = max_health
	emit_signal("health_changed", current_health)

func damage(attack: Attack) -> void:
	current_health -= attack.attack_damage
	emit_signal("taking_damage")
	emit_signal("health_changed", current_health)
	check_health()

func dot(attack: Attack) -> void:
	current_health -= attack.attack_damage
		
	for i in int(attack.dot_duration):
		await get_tree().create_timer(1).timeout
		current_health -= attack.damage_over_time
		emit_signal("taking_damage")
		emit_signal("health_changed", current_health)
		check_health()

func heal(amount: float) -> void:
	current_health = min(current_health + amount, max_health)
	emit_signal("health_changed", current_health)

func is_alive() -> bool:
	return current_health > 0

func check_health() -> void:
	if current_health <= 0:
		if get_parent().is_in_group("Player"):
			emit_signal("player_died")
		else:
			get_parent().queue_free()
