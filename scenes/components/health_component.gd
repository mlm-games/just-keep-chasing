class_name HealthComponent extends Node

signal entity_died
signal taking_damage
signal health_changed(new_health: float)

const INVINCIBLE_SHADER = preload("uid://bdl51to7btcu8")
var max_health: float 
var current_health: float = max_health
var dying: bool = false
var invincible: bool = false
var prev_health := max_health

enum HealthModificationType {
	HEAL,
	RAW_DAMAGE,
	FIRE,
}

@onready var parent : Node2D = get_parent()

func _ready() -> void:
	if parent is BaseEnemy:
		# Apply enemy health modifications from game stats
		max_health -= GameStats.get_stat(GameStats.Stats.FLAT_ENEMY_HEALTH_REDUCTION)
		max_health *= GameStats.get_stat(GameStats.Stats.ENEMY_HEALTH_MULT)
	else:
		# For player, use player health stat
		max_health = GameStats.get_stat(GameStats.Stats.PLAYER_MAX_HEALTH)
	
	current_health = max_health
	health_changed.emit(current_health)

func damage(attack: Attack) -> void:
	if not invincible:
		var final_damage : float = attack.attack_damage
		if parent is Player:
			# Apply damage reduction for player
			final_damage *= (1 - GameStats.get_stat(GameStats.Stats.PLAYER_DAMAGE_REDUCTION))
		current_health -= final_damage
		if parent is SlimeEnemy:
			CountStats.increment_stat("damage_dealt", int(final_damage))
			GameState.world.add_child(DamageNumbers.new_damage_text(final_damage, parent.global_position))
		taking_damage.emit()
		health_changed.emit(current_health)
		check_health()

func heal_or_damage(amount: float, type: HealthModificationType = HealthModificationType.RAW_DAMAGE) -> void:
	if amount > 0 and type == HealthModificationType.HEAL:
		if parent is Player:
		# Apply healing multiplier for player
		#TODO: add heal particle effects
			amount *= GameStats.get_stat(GameStats.Stats.HEALING_MULT)
			
			CountStats.total_count_stats["health_healed"] += amount
		
		var tween : Tween = create_tween().set_ease(Tween.EASE_OUT_IN)
		var color_backup : Color = parent.modulate
		tween.tween_property(parent, "modulate", Color.LIGHT_GREEN, 0.1)
		tween.tween_property(parent, "modulate", color_backup, 0.1)
	
	current_health = clampf(current_health + amount, 0, max_health)
	health_changed.emit(current_health)

func dot(attack: Attack) -> void:
	if not invincible:
		current_health -= attack.attack_damage
			
		for i in int(attack.dot_duration):
			await get_tree().create_timer(1).timeout
			current_health -= attack.damage_over_time
			taking_damage.emit()
			health_changed.emit(current_health)
			check_health()


func is_alive() -> bool:
	return current_health > 0

#func is_taking_damage(delta) -> bool:
	#var is_damaged = current_health < prev_health
	#prev_health = current_health
	#return is_damaged


func check_health() -> void:
	if not is_alive():
		entity_died.emit()

func disable_for_secs(secs: float) -> void:
	invincible = true
	var parent_sprite : Sprite2D = get_node("../Sprite2D")
	parent_sprite.material = ShaderMaterial.new()
	parent_sprite.material.shader = INVINCIBLE_SHADER
	await get_tree().create_timer(secs).timeout
	invincible = false
	parent_sprite.material = null
	

#func display_floating_dmg_numbers(dmg_val: float) -> void:
	#var nos_instance := ScreenEffects.FLOATING_DAMAGE_TEXT.instantiate()
	#nos_instance.global_position = parent.global_position
	#GameState.world.add_child(nos_instance)
	#nos_instance.display(dmg_val)
