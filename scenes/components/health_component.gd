class_name HealthComponent extends Node

signal entity_died
signal taking_damage(damage: float)
signal health_changed(new_health: float)
signal max_health_changed(new_max_health: float)
signal knockback_requested(force: Vector2, duration: float)

const INVINCIBLE_SHADER = preload("uid://bdl51to7btcu8")

#It can be set in the inspector for testing/defaults
@export var max_health: float = 100.0
@export var current_health: float

var dying: bool = false
var invincible: bool = false

enum HealthModificationType {
	HEAL,
	RAW_DAMAGE,
	FIRE,
}

@onready var parent_node: Node2D = get_parent()


func _ready() -> void:
	pass


func initialize(new_max_health: float, update_health: bool = true) -> void:
	max_health = new_max_health
	if update_health:
		current_health = max_health
	
	max_health_changed.emit(max_health)
	health_changed.emit(current_health)


func damage(attack: Attack) -> void:
	if invincible or dying:
		return

	var final_damage: float = attack.attack_damage
	if parent_node is Player:
		final_damage *= (1.0 - CharacterStats.get_stat(CharacterStats.Stats.PLAYER_DAMAGE_REDUCTION))

	current_health = max(0.0, current_health - final_damage)
	
	taking_damage.emit(final_damage)
	
	if attack.knockback_force > 0.0 and attack.knockback_direction != Vector2.ZERO:
		knockback_requested.emit(attack.knockback_force * attack.knockback_direction, attack.stun_duration)
	
	health_changed.emit(current_health)
	
	if current_health <= 0:
		check_for_death()


func heal_or_damage(amount: float, type: HealthModificationType = HealthModificationType.HEAL) -> void:
	if dying:
		return
	
	if amount > 0 and type == HealthModificationType.HEAL:
		if parent_node is Player:
		#TODO: add heal particle effects
			amount *= CharacterStats.get_stat(CharacterStats.Stats.HEALING_MULT)
			CountStats.increment_stat("health_healed", amount)
		
		var tween: Tween = create_tween().set_ease(Tween.EASE_OUT_IN)
		var color_backup: Color = parent_node.modulate
		tween.tween_property(parent_node, "modulate", Color.LIGHT_GREEN, 0.1)
		tween.tween_property(parent_node, "modulate", color_backup, 0.1)
	elif amount < 0 or type == HealthModificationType.RAW_DAMAGE:
		amount = - abs(amount)
	
	current_health = clampf(current_health + amount, 0.0, max_health)
	health_changed.emit(current_health)
	
	if current_health <= 0:
		check_for_death()


func dot(attack: Attack) -> void:
	if invincible or dying:
		return
	
	current_health -= attack.attack_damage
	taking_damage.emit(attack.attack_damage)
	health_changed.emit(current_health)
	
	for i in int(attack.dot_duration):
		await A.tree.create_timer(1.0).timeout
		if dying:
			return
		current_health -= attack.damage_over_time
		taking_damage.emit(attack.damage_over_time)
		health_changed.emit(current_health)
		check_for_death()


func is_alive() -> bool:
	return current_health > 0


func check_for_death() -> void:
	if current_health <= 0 and not dying:
		dying = true
		entity_died.emit()


func disable_for_secs(secs: float) -> void:
	invincible = true
	var parent_sprite: Sprite2D = get_node_or_null("../Sprite2D")
	if parent_sprite:
		parent_sprite.material = ShaderMaterial.new()
		parent_sprite.material.shader = INVINCIBLE_SHADER
	
	await A.tree.create_timer(secs).timeout
	
	invincible = false
	if parent_sprite:
		parent_sprite.material = null


func is_dead() -> bool:
	return dying


#TODO: remove
func check_health() -> void:
	check_for_death()
