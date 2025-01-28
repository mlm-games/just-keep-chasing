class_name BaseEnemy extends CharacterBody2D

#@onready var target = get_tree().get_first_node_in_group("Player")

var research_point_value : int
var speed: float
var contact_attack_damage: int

var health_mult: float = 1.0
var currency_mult: float = 1.0
# var currency_type: currency


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	add_to_group("On Screen Enemies")


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	remove_from_group("On Screen Enemies")
