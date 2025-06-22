class_name Player extends BaseCharacter

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var input_component: PlayerInputComponent = $PlayerInputComponent
@onready var health_component: HealthComponent = %HealthComponent
@onready var animation_component : AnimationComponent = $AnimationComponent
@onready var sprite: Sprite2D = %Sprite2D

@onready var progress_bar: ProgressBar = %ProgressBar
@onready var inventory_component: InventoryComponent = $InventoryComponent

var taking_damage := false
var base_gun: BaseGun
#TODO: A sound for reloading weapons

func _ready() -> void:
	input_component.direction_changed.connect(_on_input_direction_changed)
	health_component.max_health_changed.connect(_on_health_component_max_health_changed)
	health_component.entity_died.connect(_on_health_component_entity_died)
	health_component.health_changed.connect(_on_health_component_health_changed)
	health_component.taking_damage.connect(_on_health_component_taking_damage)
	health_component.knockback_requested.connect(velocity_component.apply_knockback)
	inventory_component.gun_switched.connect(_on_gun_switched)

	CharacterStats.stat_changed.connect(_on_character_stat_changed)

	var initial_max_health := CharacterStats.get_stat(CharacterStats.Stats.PLAYER_MAX_HEALTH)
	
	health_component.initialize(initial_max_health)

	
	var initial_gun_data = inventory_component.get_active_gun()
	if initial_gun_data:
		_equip_gun(initial_gun_data)

	

func _on_input_direction_changed(direction: Vector2) -> void:
	velocity_component.accelerate_to(direction)

func _physics_process(_delta: float) -> void:
	velocity_component.speed = CharacterStats.get_stat(CharacterStats.Stats.PLAYER_SPEED)
	
	animation_component.update_movement(velocity_component.velocity)


# NOTE: Knockback is now handled by the VelocityComponent.
# The HealthComponent should now call this instead of modifying velocity directly.
# For example, in _on_health_component_taking_damage(), you would add:
# var knockback_direction = attack.source_global_position.direction_to(global_position)
# velocity_component.apply_knockback(knockback_direction * KNOCKBACK_FORCE, 0.2)
# You no longer need `update_knock_timer` here. It's gone!


func _on_character_stat_changed(stat_key: CharacterStats.Stats, new_value: float):
	if stat_key == CharacterStats.Stats.PLAYER_MAX_HEALTH:
		health_component.set_max_health(new_value)
	elif stat_key == CharacterStats.Stats.PLAYER_SPEED:
		velocity_component.speed = new_value

func _on_health_component_entity_died() -> void:
	hide()
	input_component.set_physics_process(false)
	velocity_component.set_physics_process(false)
	process_mode = Node.PROCESS_MODE_DISABLED
	
	await get_tree().create_timer(0.5).timeout
	ScreenEffects.transition("circleIn")
	await ScreenEffects.transition_player.animation_finished
	UIManager.push_layer(preload("uid://oqyl6r1j4383"))
	ScreenEffects.transition("circleOut")

func _on_health_component_taking_damage() -> void:
	taking_damage = true
	#TODO: velocity_component.apply_knockback() here.
	ScreenEffects.screen_shake(0.1, 0.5)
	await get_tree().create_timer(0.1).timeout
	taking_damage = false


func _on_health_component_max_health_changed(new_max_health: float) -> void:
	progress_bar.max_value = new_max_health

func _on_health_component_health_changed(new_health: float) -> void:
	progress_bar.value = new_health

func update_max_health(new_max_health: float) -> void:
		health_component.initialize(new_max_health)


func _equip_gun(gun_data: GunData):
	if is_instance_valid(base_gun):
		base_gun.queue_free()

	if gun_data is ShotgunData:
		base_gun = preload("uid://rks5cvegm0tb").instantiate()
	else:
		base_gun = preload("uid://djr17spwfqlsu").instantiate()
	
	base_gun.gun_data = gun_data
	add_child(base_gun)

func _on_gun_switched(new_gun_data: GunData):
	_equip_gun(new_gun_data)
