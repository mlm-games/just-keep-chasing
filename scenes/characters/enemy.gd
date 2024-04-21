class_name Enemies extends CharacterBody2D

@export var speed:float
@onready var player = get_tree().get_first_node_in_group("Player")
var can_deal_damage:= false
var player_hitbox
var contact_attack_damage = 20
var contact_attack = Attack.new()

@onready var animation_player: AnimationPlayer = %AnimationPlayer


func _process(delta: float) -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	if abs(velocity.x) > abs(velocity.y):
		animation_player.play("follow-x")
	else:
		animation_player.play("follow-y")
	move_and_slide()
	if can_deal_damage:
		contact_attack.attack_damage = 20 * delta
		player_hitbox.damage(contact_attack)
		


func _on_hitbox_component_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		player_hitbox = area
		can_deal_damage = true


func _on_hitbox_component_area_exited(area: Area2D) -> void:
	if area is HitboxComponent:
		can_deal_damage = false


