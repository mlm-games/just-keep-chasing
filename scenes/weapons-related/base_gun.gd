class_name BaseGun extends Area2D

const RELOAD_LOOP_TIME = 0.5

#@export var unlocked: bool = false

@export var ammo: int = 0

@onready var bullet_spawn_point: Marker2D = %BulletSpawnPoint
@onready var reload_timer: Timer = %ReloadTimer
@onready var fire_rate_timer: Timer = %FireRateTimer

var _target_in_range: Array = []
var tween: Tween

@export var gun_data: GunData

func _ready() -> void:
	%Sprite2D.texture = gun_data.sprite
	%Sprite2D.scale = gun_data.sprite_scale
	%Sprite2D.position = gun_data.sprite_position
	%Sprite2D.rotation = gun_data.sprite_rotation_degrees
	%Sprite2D.flip_h = gun_data.sprite_flip_h
	
	%BulletSpawnPoint.position = gun_data.bullet_spawn_offset
	
	$CollisionShape2D.shape.radius = gun_data.targeting_range
	%ShootAudioPlayer.stream = gun_data.fire_audio
	%ReloadAudioPlayer.stream = gun_data.fire_audio #TODO
	
	reload_timer.wait_time = gun_data.reload_time
	reload_timer.one_shot = true
	reload_timer.connect("timeout", _onreload_timer_timeout)
	
	fire_rate_timer.wait_time = gun_data.fire_rate
	fire_rate_timer.one_shot = true
	fire_rate_timer.connect("timeout", _on_fire_rate_timer_timeout)
	
	

func _physics_process(_delta: float) -> void:
	#if !GameState.gameplay_options["use_auto_aim"]:
		#manual_aim_at_target()
		#return
	if not _target_in_range.is_empty():
		auto_aim_at_target()
		if fire_rate_timer.is_stopped() and reload_timer.is_stopped():
			fire_rate_timer.start()

func spawn_bullet() -> void:
	if ammo > 0:
		#var stat_key : StringName = CountStats.get_stat_key(gun_data) #FIXME: How is this an resource? Unfixable lol bug in engine?
		#CountStats.guns_fired_by_type_stats[stat_key] += 1
		%ShootAudioPlayer.play()
		
		%Sprite2D.rotation_degrees = 0
		for _i in range(gun_data.bullets_per_shot):
			var bullet_data: ProjectileData = gun_data.bullet.duplicate(true)
			if get_parent() is Player:
				bullet_data.projectile_damage *= CharacterStats.get_stat(CharacterStats.Stats.PLAYER_DAMAGE_MULT)
				bullet_data.projectile_damage += CharacterStats.get_stat(CharacterStats.Stats.RAW_DAMAGE_MOD)
				#@warning_ignore("narrowing_conversion")
				#bullet_data.projectile_range *= CharacterStats.get_stat(CharacterStats.Stats.TARGETTING_RANGE_MULT)
				#bullet_data.projectile_speed *=
			if get_parent() is SlimeEnemy:
				bullet_data.projectile_damage += CharacterStats.get_stat(CharacterStats.Stats.RAW_GUN_ENEMY_DAMAGE_REDUCTION)
				bullet_data.projectile_damage *= CharacterStats.get_stat(CharacterStats.Stats.GUN_ENEMY_DAMAGE_MULT)
				#@warning_ignore("narrowing_conversion")
				#bullet_data.projectile_range *= CharacterStats.get_stat(CharacterStats.Stats.GUN_ENEMY_TARGETTING_RANGE_MULT)
			ScreenEffects.camera_shake(gun_data.screen_shake_amplitude, gun_data.fire_rate) 
			var bullet_instance : BaseProjectile = BaseProjectile.new_instance(bullet_data)
			bullet_instance.global_position = bullet_spawn_point.global_position
			bullet_instance.global_rotation_degrees = bullet_spawn_point.global_rotation_degrees + randf_range(-gun_data.bullet_spread, gun_data.bullet_spread)
			RunData.projectile_root.add_child(bullet_instance)
		ammo -= 1

func reload() -> void:
	# Use similar anim for shooting
	%ReloadAudioPlayer.play()
	play_reload_animation()
	if not reload_timer.is_stopped():
		return
	reload_timer.start()

func _onreload_timer_timeout() -> void:
	ammo = gun_data.max_ammo

func auto_aim_at_target() -> void:
	_target_in_range = _target_in_range.filter(func(t): return is_instance_valid(t))

	if _target_in_range.is_empty(): return
	
	var closest_target: Node2D = null
	var closest_dist_sq = INF # Use squared distance to avoid costly sqrt()
	
	for target in _target_in_range:
		var dist_sq = global_position.distance_squared_to(target.global_position)
		if dist_sq < closest_dist_sq:
			closest_dist_sq = dist_sq
			closest_target = target
	
	if closest_target:
		var direction = (closest_target.global_position - global_position).normalized()

		rotation = lerp_angle(rotation, direction.angle(), CharacterStats.get_stat(CharacterStats.Stats.GUN_TARGETTING_SPEED))
		rotation = wrapf(rotation, -PI/2, 3*PI/2)

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
			reload()

func play_fire_animation() -> void:
	if tween: 
		tween.kill()
	tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUART)
	#tween.tween_property(%Sprite2D, "skew", rad_to_deg(gun_data.fire_animation_skew), gun_data.reload_time/2)
	tween.tween_property(%Sprite2D, "offset:x", -250*gun_data.fire_rate, gun_data.fire_rate/2)
	#tween.tween_property(%Sprite2D, "skew", 0, gun_data.fire_rate/2)
	tween.tween_property(%Sprite2D, "offset:x", 0, gun_data.fire_rate/2)

func play_reload_animation() -> void:
	if tween:
		tween.kill()
	tween = get_tree().create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(%Sprite2D, "rotation_degrees", snappedf(720*gun_data.reload_time/RELOAD_LOOP_TIME, 360), gun_data.reload_time)


func set_ignore_time_scale() -> void:
	reload_timer.ignore_time_scale = true
	fire_rate_timer.ignore_time_scale = true
	if tween: tween.set_ignore_time_scale()

func unset_ignore_time_scale() -> void:
	reload_timer.ignore_time_scale = false
	fire_rate_timer.ignore_time_scale = false
	if tween: tween.set_ignore_time_scale(false)
	
	
