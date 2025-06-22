class_name BaseMeleeEnemy extends BaseEnemy

const LoadedParticlesScene = preload("uid://dfbi8k6eqssuk")

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_component: HitboxComponent = %EnemyHitboxComponent
@onready var animation_component: AnimationComponent = $AnimationComponent
@onready var sprite: Sprite2D = $Sprite2D

var contact_attack_damage: float

@onready var player : Player = get_tree().get_first_node_in_group("Player")

var player_hitbox: HitboxComponent
var can_deal_damage := false


func _ready() -> void:
	super._ready()
	
	health_component.entity_died.connect(_on_health_component_entity_died)
	health_component.taking_damage.connect(animation_component.on_taking_damage)
	health_component.knockback_requested.connect(velocity_component.apply_knockback)
	
	hitbox_component.area_entered.connect(_on_hitbox_component_area_entered)
	hitbox_component.area_exited.connect(_on_hitbox_component_area_exited)
	
	set_data_values()


func set_data_values() -> void:
	if not enemy_data_resource:
		push_warning("Enemy has no EnemyData resource assigned.")
		return
		
	health_component.initialize(enemy_data_resource.base_health)
	contact_attack_damage = enemy_data_resource.base_contact_damage
	research_point_value = enemy_data_resource.research_point_value
	#velocity_component.max_speed = enemy_data_resource.base_speed
	
	scale = enemy_data_resource.character_scale
	$CollisionShape2D.shape.size = enemy_data_resource.character_hitbox_shape_value
	sprite.texture = enemy_data_resource.sprite_texture
	sprite.scale = enemy_data_resource.sprite_scale
	sprite.modulate = enemy_data_resource.sprite_color
	
	if enemy_data_resource.gun: 
		var enemy_gun: BaseGun = enemy_data_resource.gun.weapon_scene.instantiate()
		enemy_data_resource.gun.bullet = enemy_data_resource.gun.bullet.duplicate(true)
		enemy_data_resource.gun.bullet.collision_shape_mask = 2 ## Target player
		enemy_gun.gun_data = enemy_data_resource.gun
		add_child(enemy_gun)
		enemy_gun.set_collision_mask_value(3, false)
		enemy_gun.set_collision_mask_value(2, true)


func _physics_process(delta: float) -> void:
	apply_contact_damage(delta)
	if not health_component.is_dead():
		animation_component.update_movement(velocity_component.velocity)

func apply_contact_damage(delta: float) -> void:
	if can_deal_damage and player_hitbox:
		var contact_attack := Attack.new()
		contact_attack.attack_damage = contact_attack_damage * delta
		player_hitbox.damage(contact_attack)

func _on_hitbox_component_area_entered(area: Area2D) -> void:
	if area.owner is Player:
		player_hitbox = area.get_node_or_null("HitboxComponent") # Get the actual hitbox
		if not player_hitbox: player_hitbox = area # Fallback
		can_deal_damage = true

func _on_hitbox_component_area_exited(area: Area2D) -> void:
	if area == player_hitbox or (area.owner is Player and area == player_hitbox):
		player_hitbox = null
		can_deal_damage = false

func _on_health_component_entity_died() -> void:
	if not health_component.is_dead():
		GameState.emit_research_points(global_position, research_point_value)
		## NOTE: The AnimationComponent now handles the queue_free() after the death anim.
		animation_component.on_entity_died()
		

		$CollisionShape2D.set_deferred("disabled", true)
		hitbox_component.get_node("CollisionShape2D").set_deferred("disabled", true)
		set_physics_process(false)

func shake(amount: float, duration: float):
	ScreenEffects.shake(amount, duration)

func flash_sprite(color: Color, duration: float):
	if is_instance_valid(sprite):
		ScreenEffects.flash_sprite(sprite, color, duration)
