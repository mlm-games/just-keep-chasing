#Hack: Slow time powerup use using GammeState.halt
#Hack: modify line 93 to get collectRadius collisionshape node so that it can be modified to increase range
class_name ResearchPoints extends Node2D

const COLLECT_RADIUS := 120.0
const LIFETIME := 10.0
const DAMPING := 0.9
const GRAVITY := 20.0

@export var value: int = 1
@export var initial_velocity: Vector2 = Vector2.ZERO
@export var additional_velocity: Vector2 = Vector2.ZERO
@export var parent: Node = null
@export var size: float = 1.0

var velocity: Vector3 = Vector3.ZERO
var pos: Vector3 = Vector3.ZERO
var should_collect: bool = false
var collect_target: Node = null
var collect_timer: float = 0.0
var collect_target_radius: float = 0.0
var lifetime_timer: float = 0.0
var frame_timer: float = 0.0

func _ready() -> void:
	pos.x = global_position.x
	pos.y = global_position.y
	if initial_velocity == Vector2.ZERO:
		var direction = Vector2(randf_range(-1.0, 1.0), randf_range(-1.0, 1.0)).normalized()
		var speed = randf_range(100.0, 300.0)
		initial_velocity = direction * speed
	velocity = Vector3(initial_velocity.x + additional_velocity.x, initial_velocity.y + additional_velocity.y, 0.0)
	if parent:
		parent.add_child(self)
	var radius = size * 0.5
	scale = Vector2(radius, radius)
	visible = true
	if GameState.absorb_timer > 0.0:
		should_collect = true
	_update_position()

func _update_position() -> void:
	var delta = Engine.get_physics_interpolation_fraction()
	var speed_factor = 1.0 #if not GameState.halt else 0.0
	lifetime_timer += delta
	frame_timer += 1.0
	if lifetime_timer >= LIFETIME - 2.0:
		visible = int(frame_timer * 0.5) % 2 > 1.0
	if lifetime_timer >= LIFETIME:
		queue_free()
	if should_collect or int(frame_timer) % 10 == 0.0:
		_check_collect()
	if lifetime_timer > 3.0 and not should_collect:
		return
	velocity.x *= DAMPING
	velocity.y *= DAMPING
	velocity.z -= GRAVITY * delta
	pos += velocity * delta * speed_factor
	if pos.z <= 0.0:
		pos.z = 0.0
		velocity.z = -velocity.z * DAMPING
	global_position = Vector2(pos.x, pos.y)

func _check_collect() -> void:
	var target_distance := INF
	var target_angle := 0.0
	var target_node : Node2D = null
	if not collect_target or not is_instance_valid(collect_target):
		collect_target = null
		should_collect = false
	if collect_target:
		var target_diff = collect_target.global_position - global_position
		target_distance = target_diff.length()
		target_angle = target_diff.angle()
		target_node = collect_target
	if not target_node:
		var target_diff := Vector2.INF
		var closest_distance := INF
		for player in get_tree().get_nodes_in_group("Players"):
			var player_diff = player.global_position - global_position
			if abs(player_diff.x) > COLLECT_RADIUS or abs(player_diff.y) > COLLECT_RADIUS:
				continue
			var distance_squared = player_diff.length_squared()
			if distance_squared < closest_distance:
				closest_distance = distance_squared
				target_node = player
				target_diff = player_diff
		if target_diff.x != INF or target_diff.y != INF:
			target_distance = target_diff.length()
			target_angle = target_diff.angle()
	if target_distance < COLLECT_RADIUS:
		should_collect = true
		collect_target = target_node
		collect_target_radius = target_node.get_node("CollectRadius").shape.radius
	if target_distance < collect_target_radius + size * 0.5:
		if not collect_target:
			collect_target = target_node
		collect_target.collect_points(self)
	elif should_collect:
		collect_timer += 1.0
		var pull_force = (collect_target.global_position - global_position).normalized() * min(collect_timer * 10.0, 500.0)
		velocity.x += pull_force.x
		velocity.y += pull_force.y
		global_position = global_position.lerp(collect_target.global_position, 0.1)

func collect_points(target: Node) -> void:
	target.collect_research_points(value)
	queue_free()

#func collect_forcefully(target: Node) -> void:
	#if not should_collect:
		#should_collect = true
		#collect_target = target
