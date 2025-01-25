class_name SlimeEnemy extends CharacterBody2D

const ANIMATION_FOLLOW_X = "follow-x"
const ANIMATION_FOLLOW_Y = "follow-y"

@export var research_point_value : int
@export var speed: float
@export var contact_attack_damage: int = 20

@onready var player = get_tree().get_first_node_in_group("Player")
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var hitbox_component: HitboxComponent = %EnemyHitboxComponent

var player_hitbox: HitboxComponent
var can_deal_damage := false

func _ready() -> void:
	pass
	hitbox_component.health_component.entity_died.connect(_on_health_component_entity_died)
	hitbox_component.area_entered.connect(_on_hitbox_component_area_entered.bind())
	hitbox_component.area_exited.connect(_on_hitbox_component_area_exited.bind())

func _physics_process(delta: float) -> void:
	move_towards_player()
	update_animation()
	apply_contact_damage(delta)
	print($Sprite2D.scale)

func move_towards_player() -> void:
	var direction = global_position.direction_to(player.global_position)
	velocity = direction * speed
	move_and_slide()

func update_animation() -> void:
	if not animation_player.is_playing():
		if abs(velocity.x) > abs(velocity.y):
			animation_player.play(ANIMATION_FOLLOW_X)
		else:
			animation_player.play(ANIMATION_FOLLOW_Y)

func apply_contact_damage(delta: float) -> void:
	if can_deal_damage and player_hitbox:
		var contact_attack = Attack.new()
		contact_attack.attack_damage = contact_attack_damage * delta
		player_hitbox.damage(contact_attack)

func _on_hitbox_component_area_entered(area: Area2D) -> void:
	if area.get_parent() is Player:
		player_hitbox = area
		can_deal_damage = true

func _on_hitbox_component_area_exited(area: Area2D) -> void:
	if area.get_parent() is Player and player_hitbox == area:
		player_hitbox = null
		can_deal_damage = false


func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	add_to_group("On Screen Enemies")


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	remove_from_group("On Screen Enemies")


func _on_health_component_entity_died() -> void:
	if not hitbox_component.health_component.dying:
		GameState.research_points += research_point_value
		hitbox_component.health_component.dying = true
	get_tree().get_first_node_in_group("HUD").update_currency_label()
	$EnemyHitboxComponent/CollisionShape2D.set_deferred("disabled", true)
	set_physics_process(false)
	animation_player.play("death")
	await animation_player.animation_finished
	queue_free()
