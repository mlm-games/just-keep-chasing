class_name HealthComponent extends Node

signal entity_died
signal taking_damage
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

@onready var parent_node : Node2D = get_parent()

func _ready() -> void:
	pass

func initialize(new_max_health: float) -> void:
	max_health = new_max_health
	current_health = max_health
	
	max_health_changed.emit(max_health)
	health_changed.emit(current_health)


func damage(attack: Attack) -> void:
	if invincible or dying:
		return

	var final_damage: float = attack.attack_damage
	if parent_node is Player:
		# Apply damage reduction for player
		final_damage *= (1 - CharacterStats.get_stat(CharacterStats.Stats.PLAYER_DAMAGE_REDUCTION))

	current_health = max(0, current_health - final_damage)
	
	#TODO: move this to slime or base_enemy
	if parent_node is BaseEnemy:
		CountStats.increment_stat("damage_dealt", int(final_damage))
		#RunData.world.add_child(DamageNumbers.new_damage_text(final_damage, parent_node.global_position))
		VFXSpawner.spawn_damage_number(final_damage, parent_node.global_position)
	
	taking_damage.emit()
	knockback_requested.emit(attack.knockback_force * attack.knockback_direction, attack.stun_duration)
	health_changed.emit(current_health)
	
	if current_health <= 0:
		check_for_death()

func heal_or_damage(amount: float, type: HealthModificationType = HealthModificationType.RAW_DAMAGE) -> void:
	if amount > 0 and type == HealthModificationType.HEAL:
		if parent_node is Player:
		# Apply healing multiplier for player
		#TODO: add heal particle effects
			amount *= CharacterStats.get_stat(CharacterStats.Stats.HEALING_MULT)
			CountStats.total_count_stats["health_healed"] += amount
		
		var tween : Tween = create_tween().set_ease(Tween.EASE_OUT_IN)
		var color_backup : Color = parent_node.modulate
		tween.tween_property(parent_node, "modulate", Color.LIGHT_GREEN, 0.1)
		tween.tween_property(parent_node, "modulate", color_backup, 0.1)
	
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
		dying = true
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
	#var nos_instance := STransitions.FLOATING_DAMAGE_TEXT.instantiate()
	#nos_instance.global_position = parent.global_position
	#RunData.world.add_child(nos_instance)
	#nos_instance.display(dmg_val)

func check_for_death() -> void:
	if current_health <= 0 and not dying:
		dying = true
		entity_died.emit()

func is_dead() -> bool:
	return dying

func shake(amount: float, duration: float):
	pass
	#STransitions.shake(amount, duration)

func flash_sprite(color: Color, duration: float):
	pass
	#STransitions.flash_sprite(owner.sprite, color, duration)
