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

## This is the function the "Attached" state will call.
func drain_and_stick(delta: float, velocity_component: VelocityComponent):
	if not _is_attached or not is_instance_valid(_player_health): return

	var damage_to_deal = damage_per_second * delta
	_player_health.damage(damage_to_deal)
	_own_health.heal(damage_to_deal)
	
	# Instead of setting position, we tell the velocity component to match the target.
	# This avoids direct position manipulation which fights the physics engine.
	velocity_component.move_towards_target(target.global_position)

# These functions now only manage the internal state flags.
func _on_area_entered(area: Area2D):
	if area.owner.is_in_group("Player"):
		_is_attached = true
		target = area.owner
		_player_health = target.get_node("HealthComponent")

func _on_area_exited(area: Area2D):
	if area.owner == target:
		_is_attached = false
		_player_health = null
