class_name Shotgun extends Area2D
#HACK: create a class firespeedtimer which is extended so that in ready fn nothing needs to be repeated by default
var gun_capacity := 5
var pellets_per_shot := 5
var pellet_damage := 1
var pellet_spread := 20.0
var shooting_range := 500
var reload_time := 0.5
var bullets_fired := 0
var bullet_scene = preload("res://scenes/weapons-related/pellet.tscn")
var time_between_shots = 0.5
var fire_speed_timer := Timer.new()

@onready var sprite_2d: Sprite2D = %Sprite2D

var enemies_in_range := []

func _ready() -> void:
	fire_speed_timer.one_shot = true
	fire_speed_timer.connect("timeout", _on_fire_speed_timer_timeout)
	self.add_child(fire_speed_timer)
	bullets_fired = gun_capacity

func _on_area_entered(area: Area2D) -> void:
	enemies_in_range.append(area)
	if enemies_in_range.size() == 1:
		set_physics_process(true)

func _on_area_exited(area: Area2D) -> void:
	enemies_in_range.erase(area)
	if enemies_in_range.is_empty():
		set_physics_process(false)

func _physics_process(_delta: float) -> void:
	if enemies_in_range.size() > 0:
		look_at(enemies_in_range[0].global_position)
		if rotation > PI/2 || rotation < -PI/2:
			sprite_2d.flip_v = true
		else:
			sprite_2d.flip_v = false
		if fire_speed_timer.is_stopped():
			fire_speed_timer.start()
	else:
		get_targets_in_range()

func _on_fire_speed_timer_timeout() -> void:
	if bullets_fired >= gun_capacity:
		reload_gun()
	else:
		fire_shotgun()

func fire_shotgun() -> void:
	Utils.screen_shake(0.1, 1, get_viewport().get_camera_2d())
	for i in pellets_per_shot:
		var pellet = bullet_scene.instantiate()
		pellet.global_position = %BulletSpawnPoint.global_position
		pellet.global_rotation = %BulletSpawnPoint.global_rotation
		pellet.pellet_spread = pellet_spread
		pellet.pellet_damage = pellet_damage
		get_tree().current_scene.add_child(pellet)
	
	bullets_fired += 1

func reload_gun() -> void:
	%AnimationPlayer.play("reload")
	await get_tree().create_timer(reload_time).timeout
	%AnimationPlayer.stop()
	bullets_fired = 0
	fire_speed_timer.start(time_between_shots)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reload"):
		set_physics_process(true)
		reload_gun()


func get_targets_in_range() -> Array:
	var enemies = get_tree().get_nodes_in_group("On Screen Enemies")
	for enemy in enemies:
		#if there sre more than lets say 20 enemies, dont run this condition
		if enemy.global_position.distance_to(global_position) <= shooting_range:
			enemies_in_range.append(enemy)
	return enemies_in_range
