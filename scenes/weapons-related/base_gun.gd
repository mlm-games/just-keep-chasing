class_name BaseGun extends Area2D

const RELOAD_LOOP_TIME = 0.5
const BaseBulletScene = preload("res://scenes/weapons-related/base_projectile.tscn")

@export var unlocked: bool = false

# needed properites for gun data

@export var ammo: int = 0

@onready var _bullet_spawn_point: Marker2D = %BulletSpawnPoint
@onready var _reload_timer: Timer = %ReloadTimer
@onready var _fire_rate_timer: Timer = %FireRateTimer

var _target_in_range: Array = []
var tween: Tween

@export var gun_data: GunData

func _ready() -> void:
	%Sprite2D.texture = gun_data.sprite
	%Sprite2D.scale = gun_data.sprite_scale
	%Sprite2D.position = gun_data.sprite_position
	%Sprite2D.rotation = gun_data.sprite_rotation_degrees
	%Sprite2D.flip_h = gun_data.sprite_flip_h
	
	_bullet_spawn_point.position = gun_data.bullet_spawn_offset
	
	$CollisionShape2D.shape.radius = gun_data.targeting_range
	
	
	_reload_timer.wait_time = gun_data.reload_time
	_reload_timer.one_shot = true
	_reload_timer.connect("timeout", _on_reload_timer_timeout)
	
	_fire_rate_timer.wait_time = gun_data.fire_rate
	_fire_rate_timer.one_shot = true
	_fire_rate_timer.connect("timeout", _on_fire_rate_timer_timeout)
	
	

func _physics_process(_delta: float) -> void:
	if not _target_in_range.is_empty():
		aim_at_target()
		if _fire_rate_timer.is_stopped() and _reload_timer.is_stopped():
			_fire_rate_timer.start()

func spawn_bullet() -> void:
	if ammo > 0:
		%Sprite2D.rotation_degrees = 0
		for _i in range(gun_data.bullets_per_shot):
			var bullet_instance : BaseProjectile = BaseBulletScene.instantiate()
			var bullet_data: ProjectileData = gun_data.bullet.duplicate(true)
			bullet_instance.global_position = _bullet_spawn_point.global_position
			bullet_instance.global_rotation_degrees = _bullet_spawn_point.global_rotation_degrees + randf_range(-gun_data.bullet_spread, gun_data.bullet_spread)
			if get_parent() is Player:
				bullet_data.projectile_damage *= GameStats.get_stat(GameStats.Stats.PLAYER_DAMAGE_MULT)
				bullet_data.projectile_damage += GameStats.get_stat(GameStats.Stats.RAW_DAMAGE_MOD)
				#@warning_ignore("narrowing_conversion")
				#bullet_data.projectile_range *= GameStats.get_stat(GameStats.Stats.TARGETTING_RANGE_MULT)
				#bullet_data.projectile_speed *=
			if get_parent() is SlimeEnemy:
				bullet_data.projectile_damage += GameStats.get_stat(GameStats.Stats.RAW_GUN_ENEMY_DAMAGE_REDUCTION)
				bullet_data.projectile_damage *= GameStats.get_stat(GameStats.Stats.GUN_ENEMY_DAMAGE_MULT)
				#@warning_ignore("narrowing_conversion")
				#bullet_data.projectile_range *= GameStats.get_stat(GameStats.Stats.GUN_ENEMY_TARGETTING_RANGE_MULT)
			ScreenEffects.smooth_screen_shake(gun_data.screen_shake_frequency, gun_data.screen_shake_amplitude) 
			bullet_instance.projectile_data = bullet_data
			get_tree().current_scene.add_child(bullet_instance)
		ammo -= 1

func reload() -> void:
	# Use similar anim for shooting
	play_reload_animation()
	if not _reload_timer.is_stopped():
		return
	_reload_timer.start()

func _on_reload_timer_timeout() -> void:
	ammo = gun_data.max_ammo

func aim_at_target() -> void:
	if not _target_in_range.is_empty():
		var target = _target_in_range[0]
		var direction = (target.global_position - global_position).normalized()
		rotation = direction.angle()
		rotation = wrapf(rotation, -PI/2, 3*PI/2)
		

func _on_base_weapon_area_entered(area: Area2D) -> void:
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
	tween.tween_property(%Sprite2D, "skew", rad_to_deg(gun_data.fire_animation_skew), gun_data.fire_animation_duration/2)
	tween.tween_property(%Sprite2D, "skew", rad_to_deg(0), gun_data.fire_animation_duration/2)

func play_reload_animation() -> void:
	if tween:
		tween.kill()
	tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(%Sprite2D, "rotation_degrees", 360*(gun_data.reload_time/RELOAD_LOOP_TIME), gun_data.reload_time)

func set_ignore_time_scale() -> void:
	_reload_timer.ignore_time_scale = true
	_fire_rate_timer.ignore_time_scale = true
	tween.set_ignore_time_scale()

func unset_ignore_time_scale() -> void:
	_reload_timer.ignore_time_scale = false
	_fire_rate_timer.ignore_time_scale = false
	tween.set_ignore_time_scale(false)
	
	
