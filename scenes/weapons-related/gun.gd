class_name Gun extends Area2D
const GUN_CAPACITY := 5
var reload_time := 0.5
var bullets_fired := 0
## Represents gun range
var bullet_scene = preload("res://scenes/weapons-related/bullet.tscn")
var time_between_shots = 0.25

@onready var sprite_2d: Sprite2D = %Sprite2D

var enemies_in_range := []

func _ready() -> void:
	bullets_fired = GUN_CAPACITY
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
		if %FireSpeedTimer.is_stopped():
			%FireSpeedTimer.start()

func _on_fire_speed_timer_timeout() -> void:
	if bullets_fired >= GUN_CAPACITY:
		reload_gun()
	else:
		fire_bullet()

func fire_bullet() -> void:
	var bullet = bullet_scene.instantiate()
	bullet.global_position = %BulletSpawnPoint.global_position
	bullet.global_rotation = %BulletSpawnPoint.global_rotation
	get_tree().current_scene.add_child(bullet)
	bullets_fired += 1


func reload_gun() -> void:
	%AnimationPlayer.play("reload")
	await get_tree().create_timer(reload_time).timeout
	%AnimationPlayer.stop()
	bullets_fired = 0
	%FireSpeedTimer.start(time_between_shots)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reload"):
		set_physics_process(true)
		reload_gun()

