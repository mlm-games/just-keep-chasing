class_name SlimeEnemy extends CharacterBody2D

@export var speed: float
@export var contact_attack_damage: int = 20

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var hitbox_component: HitboxComponent = %HitboxComponent

var player_hitbox: HitboxComponent
var can_deal_damage := false

func _process(delta: float) -> void:
	move_towards_player()
	update_animation()
	apply_contact_damage(delta)

func move_towards_player() -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()

func update_animation() -> void:
	if abs(velocity.x) > abs(velocity.y):
		animation_player.play("follow-x")
	else:
		animation_player.play("follow-y")

func apply_contact_damage(delta: float) -> void:
	if can_deal_damage:
		var contact_attack = Attack.new()
		contact_attack.attack_damage = contact_attack_damage * delta
		player_hitbox.damage(contact_attack)

func _on_hitbox_component_area_entered(area: Area2D) -> void:
	if area is HitboxComponent:
		player_hitbox = area
		can_deal_damage = true

func _on_hitbox_component_area_exited(area: Area2D) -> void:
	if area is HitboxComponent:
		can_deal_damage = false
