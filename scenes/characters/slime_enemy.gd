class_name SlimeEnemy extends BaseEnemy

const ANIMATION_FOLLOW_X = "follow-x"
const ANIMATION_FOLLOW_Y = "follow-y"
const LoadedParticlesScene = preload("res://scenes/components/modular_hit_particles.tscn")


@onready var player = get_tree().get_first_node_in_group("Player")
@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var hitbox_component: HitboxComponent = %EnemyHitboxComponent
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

var player_hitbox: HitboxComponent
var can_deal_damage := false

func _ready() -> void:
	hitbox_component.health_component.entity_died.connect(_on_health_component_entity_died)
	hitbox_component.area_entered.connect(_on_hitbox_component_area_entered.bind())
	hitbox_component.area_exited.connect(_on_hitbox_component_area_exited.bind())
	visible_on_screen_notifier_2d.screen_entered.connect(_on_visible_on_screen_notifier_2d_screen_entered)
	visible_on_screen_notifier_2d.screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited)
	

func set_data_values(enemy_data: EnemyData):
	contact_attack_damage = enemy_data.base_contact_damage
	speed = enemy_data.base_speed
	research_point_value = enemy_data.research_point_value
	scale = enemy_data.character_scale
	$CollisionShape2D.shape = RectangleShape2D.new()
	$CollisionShape2D.shape.size = enemy_data.character_hitbox_shape_value
	$Sprite2D.texture = enemy_data.sprite_texture
	$Sprite2D.scale = enemy_data.sprite_scale
	$Sprite2D.modulate = enemy_data.sprite_color
	enemy_data_resource = enemy_data
	if enemy_data.gun != null: 
		var enemy_gun: BaseGun = enemy_data.gun.weapon_scene.instantiate()
		enemy_data.gun.bullet = enemy_data.gun.bullet.duplicate(true)
		enemy_data.gun.bullet.collision_shape_mask = 2
		enemy_gun.gun_data = enemy_data.gun
		add_child(enemy_gun)
		enemy_gun.set_collision_mask_value(3, false)
		enemy_gun.set_collision_mask_value(2, true)
		#enemy_gun.bullet.collision_shape_mask = 2

func _physics_process(delta: float) -> void:
	move_towards_player(delta)
	update_animation()
	apply_contact_damage(delta)

func move_towards_player(delta) -> void:
	var direction = global_position.direction_to(player.global_position)
	if enemy_data_resource.id == "accelerator_slime":
		velocity = velocity.lerp(direction * speed, 100 * delta)
	else:
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
		GameState.emit_research_points(global_position, research_point_value)
		#GameState.research_points += research_point_value
		hitbox_component.health_component.dying = true
		#Fixme: Update kill count
		if CountStats.enemies_killed_stats.has(enemy_data_resource.id): 
			CountStats.enemies_killed_stats[enemy_data_resource.id] += 1
		else:
			CountStats.enemies_killed_stats.get_or_add(enemy_data_resource.id, 1)
	get_tree().get_first_node_in_group("HUD").update_currency_label()
	$EnemyHitboxComponent/CollisionShape2D.set_deferred("disabled", true)
	set_physics_process(false)
	animation_player.play("death")
	await animation_player.animation_finished
	queue_free()


func _on_health_component_taking_damage() -> void:
	add_child(LoadedParticlesScene.instantiate())
	
