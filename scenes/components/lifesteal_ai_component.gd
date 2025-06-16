class_name LifestealAiComponent extends Node

@export var target: Node2D
@export var damage_per_second: float = 5.0

var _is_attached: bool = false
var _player_health: HealthComponent
var _own_health: HealthComponent

func _ready():
	_own_health = owner.get_node("HealthComponent")
	# Connect to the owner's hitbox to detect when it latches on
	var hitbox = owner.get_node("HitboxComponent")
	hitbox.area_entered.connect(_on_area_entered)
	hitbox.area_exited.connect(_on_area_exited)

func _physics_process(delta: float):
	if _is_attached and is_instance_valid(_player_health):
		var damage_to_deal = damage_per_second * delta
		_player_health.damage(damage_to_deal) # Deal damage to player
		_own_health.heal(damage_to_deal) # Heal self
		
		# Stick to the player
		owner.global_position = target.global_position

func _on_area_entered(area: Area2D):
	if area.owner.is_in_group("Player"):
		_is_attached = true
		target = area.owner # The target is the Player node
		_player_health = target.get_node("HealthComponent")
		# Disable standard movement when attached
		owner.get_node("VelocityComponent").speed = 0

func _on_area_exited(area: Area2D):
	if area.owner == target:
		_is_attached = false
		_player_health = null
		# Resume standard movement
		owner.get_node("VelocityComponent").speed = owner.enemy_data_resource.base_speed
