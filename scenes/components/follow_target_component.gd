class_name FollowTargetComponent extends Node

## Calculates the direction towards a target and emits it.
## This component does not move anything; it only provides directional data.

signal direction_changed(direction: Vector2)

## The target node to follow.
@export var target: Node2D

## If true, the component will actively run its logic in _physics_process.
@export var is_active := true

func _physics_process(_delta: float) -> void:
	if not is_active or not is_instance_valid(target):
		direction_changed.emit(Vector2.ZERO)
		return

	var owner_node := get_parent() as Node2D
	if not owner_node:
		return
	
	var direction := owner_node.global_position.direction_to(target.global_position)
	direction_changed.emit(direction)
