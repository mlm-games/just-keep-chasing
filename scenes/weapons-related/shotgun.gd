class_name Shotgun extends Area2D
var gun_capacity := 5
var pellets_per_shot := 5
var pellet_damage := 1
var pellet_spread := 20.0
var shooting_range := 500
var reload_time := 0.5
var pellets_fired := 0
@export var pellet: Projectiles
var time_between_shots = 0.5
var fire_speed_timer := Timer.new()

@onready var sprite_2d: Sprite2D = %Sprite2D

var enemies_in_range := []

func _ready() -> void:
	fire_speed_timer.one_shot = true
	fire_speed_timer.connect("timeout", _on_fire_speed_timer_timeout)
	self.add_child(fire_speed_timer)
	pellets_fired = gun_capacity


func _physics_process(_delta: float) -> void:
	if enemies_in_range.size() > 0:
		look_at(enemies_in_range[0].global_position)
		if rotation > PI/2 || rotation < -PI/2:
			sprite_2d.flip_v = true
		else:
			sprite_2d.flip_v = false
		if rotation > 3*PI/2:
			rotation = -PI/2
		if fire_speed_timer.is_stopped():
			fire_speed_timer.start()


func _on_fire_speed_timer_timeout() -> void:
	if pellets_fired >= gun_capacity:
		reload_gun()
	else:
		shoot()

func shoot() -> void:
	Utils.screen_shake(0.1, 1, get_viewport().get_camera_2d())
	for i in pellets_per_shot:
		var pellet_instance = pellet.scene.instantiate()
		pellet_instance.global_position = %BulletSpawnPoint.global_position
		pellet_instance.global_rotation = %BulletSpawnPoint.global_rotation
		pellet_instance.pellet_spread = pellet_spread
		pellet_instance.pellet_damage = pellet_damage
		get_tree().current_scene.add_child(pellet_instance)
	
	pellets_fired += 1

func reload_gun() -> void:
	%AnimationPlayer.play("reload")
	await get_tree().create_timer(reload_time).timeout
	%AnimationPlayer.stop()
	pellets_fired = 0
	fire_speed_timer.start(time_between_shots)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("reload"):
		set_physics_process(true)
		reload_gun()

