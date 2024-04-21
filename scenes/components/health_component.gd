class_name HealthComponent extends Node2D

@export var max_health: float = 10.0
var current_health: float

signal player_died
signal taking_damage

func _ready():
	current_health = max_health

func damage(attack: Attack):
	current_health-=attack.attack_damage
	taking_damage.emit()
	
	if current_health < 0:
		if get_parent().is_in_group("Player"):
			player_died.emit()
		else:
			get_parent().queue_free()

func heal(amount):
	current_health = min(current_health + amount, max_health)

func is_alive():
	return current_health > 0

