class_name BaseGun extends Area2D

const RELOAD_LOOP_TIME = 0.5

#@export var unlocked: bool = false

@export var ammo: int = 0

@onready var bullet_spawn_point: Marker2D = %BulletSpawnPoint
@onready var reload_timer: Timer = %ReloadTimer
@onready var fire_rate_timer: Timer = %FireRateTimer
@onready var closest_enemy_scan_timer: Timer = %ClosestEnemyScanTimer

var _target_in_range: Array[Area2D] = []
var closest_target : Area2D
var fire_tween: Tween
var reload_tween : Tween

@export var gun_data: GunData

func _ready() -> void:
	%Sprite2D.texture = gun_data.sprite
	%Sprite2D.scale = gun_data.sprite_scale
	%Sprite2D.position = gun_data.sprite_position
	%Sprite2D.rotation = gun_data.sprite_rotation_degrees
	%Sprite2D.flip_h = gun_data.sprite_flip_h
	
	%BulletSpawnPoint.position = gun_data.bullet_spawn_offset
	
	$CollisionShape2D.shape.radius = gun_data.targeting_range
	#%ReloadAudioPlayer.stream = gun_data.fire_audio #TODO
	
	reload_timer.wait_time = gun_data.reload_time
	reload_timer.timeout.connect(_on_reload_timer_timeout)
	
	fire_rate_timer.wait_time = gun_data.fire_rate
	fire_rate_timer.start()
	fire_rate_timer.timeout.connect(_on_fire_rate_timer_timeout)
	
	closest_enemy_scan_timer.timeout.connect(_on_scan_for_closest_enemy_timer_timeout)
	

func _physics_process(_delta: float) -> void:
	if not _target_in_range.is_empty():
		auto_aim_at_target()
	#if !GameState.gameplay_options["use_auto_aim"]:
		#manual_aim_at_target()
		#return


func _on_scan_for_closest_enemy_timer_timeout() -> void:
	if not _target_in_range.is_empty():
		closest_target = _get_closest_target()


func spawn_bullet() -> void:
	if ammo > 0:
		CountStats.increment_stat(CountStats.get_stat_key(gun_data))
		StaticAudioM.play_random_sound(gun_data.fire_audio)
		
		%Sprite2D.rotation_degrees = 0
		for _i in range(gun_data.bullets_per_shot):
			var bullet_data: ProjectileData = gun_data.bullet.duplicate_with_res_name()
			bullet_data.projectile_speed_dropoff_curve = gun_data.speed_dropoff_curve
			ScreenEffects.camera_shake(gun_data.screen_shake_amplitude, gun_data.fire_rate) 
			var bullet_instance : BaseProjectile = InstanceManager.new_projectile_instance(bullet_data, get_parent())
			bullet_instance.global_position = bullet_spawn_point.global_position
			bullet_instance.global_rotation_degrees = bullet_spawn_point.global_rotation_degrees + randf_range(-gun_data.bullet_spread, gun_data.bullet_spread)
			RunData.projectile_root.add_child(bullet_instance)
		ammo -= 1

func reload() -> void:
	# Use similar anim for shooting
	#StaticAudioM.play_sound_varied(preload("res://assets/music/gun sounds by q009/outofammo.ogg"))
	play_reload_animation()
	if not reload_timer.is_stopped():
		return
	reload_timer.start()

func _on_reload_timer_timeout() -> void:
	ammo = gun_data.max_ammo
	fire_rate_timer.start()


func _get_closest_target() -> Area2D:
	_target_in_range = _target_in_range.filter(func(t): return is_instance_valid(t))

	if _target_in_range.is_empty(): return
	
	closest_target = null
	var closest_dist_sq = INF # Use squared distance to avoid costly sqrt()
	
	for target in _target_in_range:
		var dist_sq = global_position.distance_squared_to(target.global_position)
		if dist_sq < closest_dist_sq:
			closest_dist_sq = dist_sq
			closest_target = target
	
	return closest_target

func auto_aim_at_target() -> void:
	closest_target = _get_closest_target()
	if is_instance_valid(closest_target):
		var direction = (closest_target.global_position - global_position).normalized()

		rotation = lerp_angle(rotation, direction.angle(), CharacterStats.get_stat(CharacterStats.Stats.GUN_TARGETTING_SPEED))
		rotation = wrapf(rotation, -PI/2, 3*PI/2)
	else:
		closest_target = _get_closest_target()

func manual_aim_at_target() -> void:
	var direction : Vector2 = GameState.shooting_joystick_direction
	rotation = lerp_angle(rotation, direction.angle(), CharacterStats.get_stat(CharacterStats.Stats.GUN_TARGETTING_SPEED))
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
		if reload_timer.is_stopped(): reload()
	else:
		fire_rate_timer.start()

func play_fire_animation() -> void:
	fire_tween = Juice.create_global_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	#tween.tween_property(%Sprite2D, "skew", rad_to_deg(gun_data.fire_animation_skew), gun_data.reload_time/2)
	fire_tween.tween_property(%Sprite2D, "offset:x", -250*gun_data.fire_rate, gun_data.fire_rate/2)
	#fire_tween.tween_property(%Sprite2D, "skew", 0, gun_data.fire_rate/2)
	fire_tween.tween_property(%Sprite2D, "offset:x", 0, gun_data.fire_rate/2)

func play_reload_animation() -> void:
	reload_tween = Juice.create_global_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	reload_tween.tween_property(%Sprite2D, "rotation_degrees", snappedf(720*gun_data.reload_time/RELOAD_LOOP_TIME, 360), gun_data.reload_time)


func set_ignore_time_scale() -> void:
	reload_timer.ignore_time_scale = true
	fire_rate_timer.ignore_time_scale = true
	if fire_tween: fire_tween.set_ignore_time_scale()
	if reload_tween: reload_tween.set_ignore_time_scale()

func unset_ignore_time_scale() -> void:
	reload_timer.ignore_time_scale = false
	fire_rate_timer.ignore_time_scale = false
	if fire_tween: fire_tween.set_ignore_time_scale(false)
	if reload_tween: reload_tween.set_ignore_time_scale(false)
	
	
