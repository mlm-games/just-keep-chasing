class_name SlimeEnemy extends BaseEnemy

const ANIMATION_FOLLOW_X = "follow-x"
const ANIMATION_FOLLOW_Y = "follow-y"
const LoadedParticlesScene = preload("uid://dfbi8k6eqssuk")

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var follow_component: FollowTargetComponent = $FollowTargetComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_component: HitboxComponent = %EnemyHitboxComponent
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var contact_attack_damage: float

@onready var player : Player = get_tree().get_first_node_in_group("Player")

var player_hitbox: HitboxComponent
var can_deal_damage := false


func _ready() -> void:
	set_data_values()
	follow_component.target = player
	follow_component.direction_changed.connect(_on_follow_direction_changed)

	hitbox_component.health_component.entity_died.connect(_on_health_component_entity_died)
	hitbox_component.area_entered.connect(_on_hitbox_component_area_entered)
	hitbox_component.area_exited.connect(_on_hitbox_component_area_exited)
	visible_on_screen_notifier_2d.screen_entered.connect(_on_visible_on_screen_notifier_2d_screen_entered)
	visible_on_screen_notifier_2d.screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited)
	
	health_component.knockback_requested.connect(velocity_component.apply_knockback)
	health_component.max_health = enemy_data_resource.base_health
	health_component.current_health = health_component.max_health

func set_data_values() -> void:
	contact_attack_damage = enemy_data_resource.base_contact_damage
	research_point_value = enemy_data_resource.research_point_value
	scale = enemy_data_resource.character_scale
	
	velocity_component.speed = enemy_data_resource.base_speed
	
	$CollisionShape2D.shape = RectangleShape2D.new()
	$CollisionShape2D.shape.size = enemy_data_resource.character_hitbox_shape_value
	$Sprite2D.texture = enemy_data_resource.sprite_texture
	$Sprite2D.scale = enemy_data_resource.sprite_scale
	$Sprite2D.modulate = enemy_data_resource.sprite_color
	
	if enemy_data_resource.gun != null: 
		var enemy_gun: BaseGun = enemy_data_resource.gun.weapon_scene.instantiate()
		enemy_data_resource.gun.bullet = enemy_data_resource.gun.bullet.duplicate(true)
		enemy_data_resource.gun.bullet.collision_shape_mask = 2
		enemy_gun.gun_data = enemy_data_resource.gun
		add_child(enemy_gun)
		enemy_gun.set_collision_mask_value(3, false)
		enemy_gun.set_collision_mask_value(2, true)


func _physics_process(delta: float) -> void:
	update_animation()
	apply_contact_damage(delta)

func _on_follow_direction_changed(direction: Vector2) -> void:
	velocity_component.accelerate_in_direction(direction)


func update_animation() -> void:
	var current_velocity = velocity_component.velocity
	
	if not animation_player.is_playing():
		if abs(current_velocity.x) > abs(current_velocity.y):
			animation_player.play(ANIMATION_FOLLOW_X)
		else:
			animation_player.play(ANIMATION_FOLLOW_Y)

func apply_contact_damage(delta: float) -> void:
	if can_deal_damage and player_hitbox:
		var contact_attack := Attack.new()
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
		GameState.emit_research_points(global_position, research_point_value)
		hitbox_component.health_component.dying = true
		#FIXME: Choose the packedscene.name instead... CountStats.enemies_type_killed_stats[enemy_data_resource] += 1
	
	$EnemyHitboxComponent/CollisionShape2D.set_deferred("disabled", true)
	follow_component.is_active = false
	#set_physics_process(false)
	
	animation_player.play("death")
	await animation_player.animation_finished
	queue_free()

# Knockback is now handled by calling the component's method.
# You would call this from your HealthComponent or HitboxComponent when damage is taken.
# Example:
# func _on_health_component_taking_damage(attack: Attack):
#     if attack.knockback_force > 0:
#         var direction = attack.source_global_position.direction_to(global_position)
#         velocity_component.apply_knockback(direction * attack.knockback_force)
#     add_child(LoadedParticlesScene.instantiate())
