extends Area2D
@export var gun_capacity := 30
var reload_time := 3.0
var bullets_fired := 0
var bullet_speed := 750
var bullet_range := 1500
@export var bullet: Projectiles
var time_between_shots = 0.1

@onready var sprite_2d: Sprite2D = %Sprite2D

var enemies_in_range := []

func _ready() -> void:
	bullets_fired = gun_capacity
	set_physics_process(false)

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
		if rotation > 3*PI/2:
			rotation = -PI/2
		if %FireSpeedTimer.is_stopped():
			%FireSpeedTimer.start()

func _on_fire_speed_timer_timeout() -> void:
	if bullets_fired >= gun_capacity:
		reload_gun()
	else:
		fire_bullet()

func fire_bullet() -> void:
	var bullet_instance = bullet.scene.instantiate()
	bullet_instance.global_position = %BulletSpawnPoint.global_position
	bullet_instance.global_rotation = %BulletSpawnPoint.global_rotation
	bullet_instance.speed = bullet_speed
	bullet_instance.bullet_range = bullet_range
	get_tree().current_scene.add_child(bullet_instance)
	bullets_fired += 1

func reload_gun() -> void:
	%AnimationPlayer.play("reload")
	await get_tree().create_timer(reload_time).timeout
	%AnimationPlayer.stop()
	bullets_fired = 0
	%FireSpeedTimer.start(time_between_shots)
