class_name Prion extends BaseEnemy

@export var projectile_scene: PackedScene
@export var min_distance: float = 500.0
@export var max_distance: float = 700.0
@export var fire_cooldown: float = 2.5
@export var aim_duration: float = 0.7

@onready var health_component: HealthComponent = $HealthComponent
@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var animation_component: AnimationComponent = $AnimationComponent
@onready var fire_cooldown_timer: Timer = $FireCooldownTimer
@onready var sprite: Sprite2D = $Sprite2D

@onready var player : Player = get_tree().get_first_node_in_group("Player")


enum SelfState { REPOSITIONING, AIMING }
var current_state: SelfState = SelfState.REPOSITIONING


func _ready() -> void:
	super._ready()
	fire_cooldown_timer.wait_time = fire_cooldown
	fire_cooldown_timer.one_shot = true
	fire_cooldown_timer.timeout.connect(_fire_shot)
	fire_cooldown_timer.start()

func _physics_process(delta: float) -> void:
	#super._physics_process(delta)
	
	if health_component.is_dead() or not is_instance_valid(player): 
		velocity_component.accelerate_to(Vector2.ZERO, 0)
		animation_component.update_movement(velocity_component.velocity)
		return

	match current_state:
		SelfState.REPOSITIONING:
			_state_repositioning()
		SelfState.AIMING:
			_state_aiming()

	animation_component.update_movement(velocity_component.velocity)

func _state_repositioning() -> void:
	var distance_to_player = global_position.distance_to(player.global_position)
	var direction_from_player = player.global_position.direction_to(global_position)
	var move_direction = Vector2.ZERO

	if distance_to_player > max_distance:
		move_direction = -direction_from_player # Move towards player
	elif distance_to_player < min_distance:
		move_direction = direction_from_player # Move away from player
	
	velocity_component.accelerate_to(move_direction, enemy_data_resource.base_speed)

func _state_aiming() -> void:
	# Stop moving while aiming
	velocity_component.accelerate_to(Vector2.ZERO, 0)

func _fire_shot() -> void:
	if not projectile_scene or health_component.is_dead() or not is_instance_valid(player): return

	var projectile_container = get_tree().get_first_node_in_group("ProjectilesContainer")
	if not projectile_container: 
		push_warning("Prion: Could not find a 'ProjectilesContainer' node group to spawn projectile in.")
		return
		
	var projectile = projectile_scene.instantiate()
	projectile_container.add_child(projectile)
	
	projectile.global_position = global_position
	projectile.rotation = global_position.direction_to(player.global_position).angle()

	# Restart the cooldown timer to fire again later
	fire_cooldown_timer.start()
	current_state = SelfState.REPOSITIONING

func _on_fire_cooldown_timer_timeout():
	if current_state == SelfState.REPOSITIONING and not health_component.is_dead():
		current_state = SelfState.AIMING
		# Start the aiming "tell" animation
		var tween = create_tween()
		var original_color = enemy_data_resource.sprite_color if enemy_data_resource else Color.WHITE
		tween.tween_property(sprite, "modulate", Color.CYAN, aim_duration * 0.8).set_ease(Tween.EASE_IN)
		tween.tween_callback(_fire_shot)
		tween.tween_property(sprite, "modulate", original_color, aim_duration * 0.2).set_ease(Tween.EASE_OUT)
