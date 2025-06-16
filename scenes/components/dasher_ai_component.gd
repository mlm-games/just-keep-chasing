class_name DasherAiComponent extends Node

signal direction_changed(direction: Vector2)

@export var target: Node2D
@export var patrol_speed: float = 50.0
@export var dash_speed: float = 400.0
@export var dash_cooldown: float = 2.0
@export var detection_radius: float = 300.0

@onready var cooldown_timer: Timer = $Timer

var _can_dash: bool = true

func _physics_process(delta):
	if not is_instance_valid(target): return

	var direction_to_target = (target.global_position - owner.global_position)
	
	if direction_to_target.length() < detection_radius and _can_dash:
		# Dash state
		direction_changed.emit(direction_to_target.normalized() * dash_speed)
		_can_dash = false
		cooldown_timer.start(dash_cooldown)
	elif not _can_dash:
		# Cooldown state - stop moving
		direction_changed.emit(Vector2.ZERO)
	else:
		# Patrol state
		# Could add more complex patrolling logic here later
		direction_changed.emit(direction_to_target.normalized() * patrol_speed)

func _on_cooldown_timer_timeout():
	_can_dash = true
