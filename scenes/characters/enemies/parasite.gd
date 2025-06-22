class_name Parasite extends BaseEnemy

@export var toxic_pool_scene: PackedScene
@export var drop_interval: float = 1.5
@export var move_change_interval: float = 2.0

@onready var health_component: HealthComponent = $HealthComponent
@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var animation_component: AnimationComponent = $AnimationComponent
@onready var move_timer: Timer = $MoveTimer
@onready var drop_pool_timer: Timer = $DropPoolTimer

var move_direction: Vector2 = Vector2.ZERO

func _ready() -> void:
	super._ready()
	
	move_timer.wait_time = move_change_interval
	move_timer.timeout.connect(_on_move_timer_timeout)
	move_timer.start()
	
	drop_pool_timer.wait_time = drop_interval
	drop_pool_timer.timeout.connect(_on_drop_pool_timer_timeout)
	drop_pool_timer.start()
	
	_on_move_timer_timeout()

func _physics_process(delta: float) -> void:
	#super._physics_process(delta)
	if health_component.is_dead(): 
		velocity_component.accelerate_to(Vector2.ZERO, 0)
		return
	
	velocity_component.accelerate_to(move_direction, enemy_data_resource.base_speed)
	animation_component.update_movement(velocity_component.velocity)

func _on_move_timer_timeout() -> void:
	move_direction = Vector2.from_angle(randf_range(0, TAU))

func _on_drop_pool_timer_timeout() -> void:
	if not toxic_pool_scene or health_component.is_dead(): return

	var pool_container = get_tree().get_first_node_in_group("ProjectilesContainer")
	if not pool_container:
		push_warning("Parasite: Could not find a 'ProjectilesContainer' node group to spawn pool in.")
		return

	var pool = toxic_pool_scene.instantiate()
	pool_container.add_child(pool)
	pool.global_position = global_position
