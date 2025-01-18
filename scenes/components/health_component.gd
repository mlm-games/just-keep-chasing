class_name HealthComponent extends Node
#TODO: Sending out the anims for each powerups (like shockwaves for screenblast, starry colors on player for invincible)
signal player_died
signal taking_damage
signal health_changed(new_health: float)

@export var max_health: float 
var current_health: float = max_health
var dying: bool = false
var invincible: bool = false
var prev_health := max_health

func _ready() -> void:
	current_health = max_health
	health_changed.emit(current_health)

func damage(attack: Attack) -> void:
	if not invincible:
		current_health -= attack.attack_damage
		taking_damage.emit()
		health_changed.emit(current_health)
		check_health()

func dot(attack: Attack) -> void:
	if not invincible:
		current_health -= attack.attack_damage
			
		for i in int(attack.dot_duration):
			await get_tree().create_timer(1).timeout
			current_health -= attack.damage_over_time
			taking_damage.emit()
			health_changed.emit(current_health)
			check_health()

func heal_or_damage(amount: float) -> void:
	current_health = clampf(current_health + amount, 0, max_health)
	health_changed.emit(current_health) 


func is_alive() -> bool:
	return current_health > 0

#func is_taking_damage(delta) -> bool:
	#var is_damaged = current_health < prev_health
	#prev_health = current_health
	#return is_damaged


func check_health() -> void:
	if not is_alive():
		if get_parent() is Player:
			player_died.emit()
		if get_parent() is SlimeEnemy and not dying:
			dying = true
			GameState.research_points += get_parent().research_point_value
			get_tree().get_first_node_in_group("HUD").update_currency_label()
			get_parent().queue_free()

func disable_for_secs(secs: float) -> void:
	invincible = true
	await get_tree().create_timer(secs).timeout
	invincible = false
	
