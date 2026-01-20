class_name LifestealAiComponent extends Node

signal attached
signal detached

@export var target: Node2D
@export var damage_per_second: float = 5.0

var _is_attached: bool = false
var _player_health: HealthComponent
var _own_health: HealthComponent


func _ready() -> void:
	_own_health = owner.get_node_or_null("HealthComponent")
	if not _own_health:
		push_error("LifestealAiComponent: Owner is missing HealthComponent")
		return
	
	var hitbox = owner.get_node_or_null("EnemyHitboxComponent")
	if not hitbox:
		hitbox = owner.get_node_or_null("HitboxComponent")
	
	if hitbox:
		hitbox.area_entered.connect(_on_area_entered)
		hitbox.area_exited.connect(_on_area_exited)
	else:
		push_error("LifestealAiComponent: Owner is missing HitboxComponent")


func is_attached() -> bool:
	return _is_attached


func drain_and_stick(delta: float, velocity_component: VelocityComponent) -> void:
	if not _is_attached or not is_instance_valid(_player_health):
		return
	
	var damage_to_deal = damage_per_second * delta
	
	# Create attack for damaging player
	var attack = Attack.new()
	attack.attack_damage = damage_to_deal
	_player_health.damage(attack)
	
	_own_health.heal_or_damage(damage_to_deal, HealthComponent.HealthModificationType.HEAL)
	
	# Stick to target (move to a parent component later)
	if is_instance_valid(target) and velocity_component:
		var direction = (target.global_position - owner.global_position)
		if direction.length() > 5.0:
			velocity_component.accelerate_to(direction.normalized(), 500.0)
		else:
			velocity_component.accelerate_to(Vector2.ZERO, 0.0)


func _on_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		_is_attached = true
		target = area.owner
		_player_health = target.get_node_or_null("HealthComponent")
		attached.emit()


func _on_area_exited(area: Area2D) -> void:
	if area.owner == target:
		_is_attached = false
		_player_health = null
		target = null
		detached.emit()