class_name HitboxComponent extends Area2D

@export var health_component: HealthComponent

func _ready() -> void:
	if not health_component:
		health_component = get_parent().get_node_or_null("HealthComponent")
		
	if not health_component:
		push_error("HitboxComponent: HealthComponent not found on parent node.")

func damage(attack: Attack) -> void:
	if health_component:
		health_component.damage(attack)

func dot(attack: Attack) -> void:
	if health_component:
		health_component.dot(attack)
