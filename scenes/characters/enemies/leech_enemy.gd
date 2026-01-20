class_name LeechEnemy extends BaseMeleeEnemy

@onready var lifesteal_component: LifestealAiComponent = $LifestealAiComponent

enum LeechState { CHASING, ATTACHED }
var current_state: LeechState = LeechState.CHASING


func _ready() -> void:
	super._ready()
	
	if lifesteal_component:
		lifesteal_component.attached.connect(_on_attached)
		lifesteal_component.detached.connect(_on_detached)


func _physics_process(delta: float) -> void:
	if health_component.is_dead():
		velocity_component.stop()
		return
	
	match current_state:
		LeechState.CHASING:
			_state_chasing(delta)
		LeechState.ATTACHED:
			_state_attached(delta)
	
	animation_component.update_movement(velocity_component.velocity)


func _state_chasing(delta: float) -> void:
	if is_instance_valid(player):
		var direction = (player.global_position - global_position).normalized()
		velocity_component.accelerate_to(direction, enemy_data_resource.base_speed)


func _state_attached(delta: float) -> void:
	if lifesteal_component:
		lifesteal_component.drain_and_stick(delta, velocity_component)


func _on_attached() -> void:
	current_state = LeechState.ATTACHED


func _on_detached() -> void:
	current_state = LeechState.CHASING