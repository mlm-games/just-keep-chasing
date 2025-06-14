class_name Player extends BaseCharacter

@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var input_component: PlayerInputComponent = $PlayerInputComponent
@onready var health_component: HealthComponent = %HealthComponent
@onready var animation_tree: AnimationTree = $AnimationTree
@onready var sprite: Sprite2D = %Sprite2D

@onready var progress_bar: ProgressBar = %ProgressBar

var taking_damage := false
var base_gun: BaseGun


func _ready() -> void:
	input_component.direction_changed.connect(_on_input_direction_changed)
	health_component.max_health_changed.connect(_on_health_component_max_health_changed)
	health_component.entity_died.connect(_on_health_component_entity_died)
	health_component.health_changed.connect(_on_health_component_health_changed)
	health_component.taking_damage.connect(_on_health_component_taking_damage)

	var initial_max_health := CharacterStats.get_stat(CharacterStats.Stats.PLAYER_MAX_HEALTH)
	
	health_component.initialize(initial_max_health)


	var initial_gun_data: GunData = GameState.collection_res.guns["pistol"]
	base_gun = initial_gun_data.weapon_scene.instantiate()
	base_gun.gun_data = initial_gun_data
	add_child(base_gun)
		
	animation_tree.active = true

func _on_input_direction_changed(direction: Vector2) -> void:
	velocity_component.accelerate_in_direction(direction)

func _physics_process(_delta: float) -> void:
	velocity_component.speed = CharacterStats.get_stat(CharacterStats.Stats.PLAYER_SPEED)
	
	update_animation()

func update_animation() -> void:
	var current_velocity := velocity_component.velocity
	
	if current_velocity.x > 0:
		sprite.flip_h = true
	elif current_velocity.x < 0:
		sprite.flip_h = false
	
	animation_tree.set("parameters/blend_position", current_velocity)


# NOTE: Knockback is now handled by the VelocityComponent.
# The HealthComponent should now call this instead of modifying velocity directly.
# For example, in _on_health_component_taking_damage(), you would add:
# var knockback_direction = attack.source_global_position.direction_to(global_position)
# velocity_component.apply_knockback(knockback_direction * KNOCKBACK_FORCE, 0.2)
# You no longer need `update_knock_timer` here. It's gone!


func _on_health_component_entity_died() -> void:
	hide()
	input_component.set_physics_process(false)
	velocity_component.set_physics_process(false)
	process_mode = Node.PROCESS_MODE_DISABLED
	
	await get_tree().create_timer(0.5).timeout
	ScreenEffects.change_scene_with_transition("uid://oqyl6r1j4383", "circleIn")

func _on_health_component_taking_damage() -> void:
	taking_damage = true
	#TODO: call velocity_component.apply_knockback() here.
	ScreenEffects.screen_shake(0.1, 0.5)
	await get_tree().create_timer(0.1).timeout
	taking_damage = false


func _on_health_component_max_health_changed(new_max_health: float) -> void:
	progress_bar.max_value = new_max_health

func _on_health_component_health_changed(new_health: float) -> void:
	progress_bar.value = new_health

func update_max_health(new_max_health: float) -> void:
		health_component.initialize(new_max_health)
