class_name BaseGun extends Area2D

const RELOAD_LOOP_TIME = 0.5
const BaseBulletScene = preload("res://scenes/weapons-related/base_projectile.tscn")

@export var unlocked: bool = false

# needed properites for gun data

@export var bullet: ProjectileData
@export var reload_time: float
@export var max_ammo: int
@export var ammo: int = max_ammo
@export var targeting_range: float
@export var fire_rate: float
@export var fire_audio: AudioStreamWAV
@export var damage_dropoff_curve: Curve
@export var speed_dropoff_curve: Curve
@export var bullet_spawn_pos: Vector2
#@export var recoil_dist: float = 5
@export var bullets_per_shot: float
@export var bullet_spread: float
@export var screen_shake_frequency : float #= 10
@export var screen_shake_amplitude : float #= 0.5

@onready var _bullet_spawn_point: Marker2D = %BulletSpawnPoint
@onready var _reload_timer: Timer = %ReloadTimer
@onready var _fire_rate_timer: Timer = %FireRateTimer
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var _target_in_range: Array = []
var tween

@export var gun_data: GunData

func _ready() -> void:
	%Sprite2D.texture = gun_data.sprite
	%Sprite2D.scale = gun_data.sprite_scale
	%Sprite2D.position = gun_data.sprite_position
	%Sprite2D.rotation = gun_data.sprite_rotation_degrees
	%Sprite2D.flip_h = gun_data.sprite_flip_h
	
	_bullet_spawn_point.position = gun_data.bullet_spawn_offset
	
	set_gun_properties(gun_data)
	
	_reload_timer.wait_time = reload_time
	_reload_timer.one_shot = true
	_reload_timer.connect("timeout", _on_reload_timer_timeout)
	
	_fire_rate_timer.wait_time = fire_rate
	_fire_rate_timer.one_shot = true
	_fire_rate_timer.connect("timeout", _on_fire_rate_timer_timeout)
	
	

func _physics_process(_delta: float) -> void:
	if not _target_in_range.is_empty():
		aim_at_target()
		if _fire_rate_timer.is_stopped() and _reload_timer.is_stopped():
			_fire_rate_timer.start()

func spawn_bullet() -> void:
	if ammo > 0:
		for _i in range(bullets_per_shot):
			var bullet_instance : BaseProjectile = BaseBulletScene.instantiate()
			var bullet_data: ProjectileData = bullet.duplicate(true)
			bullet_instance.global_position = _bullet_spawn_point.global_position
			bullet_instance.global_rotation_degrees = _bullet_spawn_point.global_rotation_degrees + randf_range(-bullet_spread, bullet_spread)
			if get_parent() is Player:
				bullet_data.projectile_damage *= GameStats.get_stat(GameStats.Stats.PLAYER_DAMAGE_MULT)
				bullet_data.projectile_damage += GameStats.get_stat(GameStats.Stats.RAW_DAMAGE_MOD)
				#bullet_data.projectile_range *= GameStats.get_stat(GameStats.Stats.BULLET_RANGE_MULT)
				#bullet_data.projectile_speed *=
			if get_parent() is SlimeEnemy:
				bullet_data.projectile_damage += GameStats.get_stat(GameStats.Stats.RAW_GUN_ENEMY_DAMAGE_REDUCTION)
				bullet_data.projectile_damage *= GameStats.get_stat(GameStats.Stats.GUN_ENEMY_DAMAGE_MULT)
				#bullet_data.projectile_range *= GameStats.get_stat(GameStats.Stats.GUN_ENEMY_BULLET_RANGE_MULT)
			ScreenEffects.smooth_screen_shake(screen_shake_frequency, screen_shake_amplitude) 
			bullet_instance.projectile_data = bullet_data
			get_tree().current_scene.add_child(bullet_instance)
		ammo -= 1

func reload() -> void:
	# Use similar anim for shooting
	animation_player.play("reload")
	if not _reload_timer.is_stopped():
		return
	_reload_timer.start()

func _on_reload_timer_timeout() -> void:
	ammo = max_ammo
	animation_player.stop()

func aim_at_target() -> void:
	if not _target_in_range.is_empty():
		var target_target = _target_in_range[0]
		var direction = (target_target.global_position - global_position).normalized()
		rotation = direction.angle()
		rotation = wrapf(rotation, -PI/2, 3*PI/2)
		

func _on_base_weapon_area_entered(area: Area2D) -> void:
#	if area.get_parent().is_in_group("Enemies") and area.global_position.distance_to(global_position) <= targeting_range:
		_target_in_range.append(area)

func _on_base_weapon_area_exited(area: Area2D) -> void:
#	if area.get_parent().is_in_group("Enemies"):
		_target_in_range.erase(area)

func _on_fire_rate_timer_timeout() -> void:
	if not _target_in_range.is_empty():
		play_fire_animation()
		spawn_bullet()
		if ammo <= 0:
			reload()

func play_fire_animation() -> void:
	if tween:
		tween.kill()
	tween = get_tree().create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(%Sprite2D, "skew", gun_data.fire_animation_skew*0.025, gun_data.fire_animation_duration/2)
	tween.tween_property(%Sprite2D, "skew", 0, gun_data.fire_animation_duration/2)

#func play_reload_animation() -> void:
	#tween.set_loops(reload_time/RELOAD_LOOP_TIME)
	
	#tween.tween_property(%Sprite2D, "rotation", 720, RELOAD_LOOP_TIME)
	#await tween.finished
	#tween.set_loops(0)


func set_gun_properties(local_gun_data: GunData) -> void:
	# Apply new gundata properties
	gun_data = local_gun_data
	# Set up sprite
	
	 # Set up bullet spawn point
	
	 # Set up timers
	reload_time = gun_data.reload_time
	fire_rate = gun_data.fire_rate
	
	# Set other properties
	max_ammo = gun_data.max_ammo
	ammo = gun_data.ammo
	targeting_range = gun_data.targeting_range
	
	bullet = gun_data.bullet
	
	bullets_per_shot = local_gun_data.bullets_per_shot
	bullet_spread = local_gun_data.bullet_spread
	screen_shake_amplitude = local_gun_data.screen_shake_amplitude
	screen_shake_frequency = local_gun_data.screen_shake_frequency
