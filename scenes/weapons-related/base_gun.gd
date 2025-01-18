class_name BaseGun extends Area2D

@export var bullet: Projectiles
@export var reload_time: float
@export var max_ammo: int
@export var ammo: int = max_ammo
@export var targeting_range: float
@export var fire_rate: float
@export var fire_audio: AudioStreamWAV
@export var damage_dropoff_curve: Curve
@export var speed_dropoff_curve: Curve
#@export var recoil_dist: float = 5

@onready var _bullet_spawn_point: Marker2D = %BulletSpawnPoint
@onready var _reload_timer: Timer = %ReloadTimer
@onready var _fire_rate_timer: Timer = %FireRateTimer
@onready var animation_player: AnimationPlayer = %AnimationPlayer

var _enemies_in_range: Array = []

func _ready() -> void:
	#$CollisionShape2D.shape.radius = 600
	_reload_timer.wait_time = reload_time
	_reload_timer.one_shot = true
	_reload_timer.connect("timeout", _on_reload_timer_timeout)
	
	_fire_rate_timer.wait_time = fire_rate
	_fire_rate_timer.one_shot = true
	_fire_rate_timer.connect("timeout", _on_fire_rate_timer_timeout)
	
	

func _physics_process(_delta: float) -> void:
	if not _enemies_in_range.is_empty():
		aim_at_enemy()
		if _fire_rate_timer.is_stopped() and _reload_timer.is_stopped():
			_fire_rate_timer.start()

func spawn_bullet() -> void:
	# Gun moves slight back and forth
	if ammo > 0:
		var bullet_instance = bullet.scene.instantiate()
		bullet_instance.global_position = _bullet_spawn_point.global_position
		bullet_instance.global_rotation = _bullet_spawn_point.global_rotation
		get_tree().current_scene.add_child(bullet_instance)
		ammo -= 1
		if ammo <= 0:
			reload()

func reload() -> void:
	# Use similar anim for shooting
	animation_player.play("reload")
	if not _reload_timer.is_stopped():
		return
	_reload_timer.start()

func _on_reload_timer_timeout() -> void:
	ammo = max_ammo
	animation_player.stop()

func aim_at_enemy() -> void:
	if not _enemies_in_range.is_empty():
		var target_enemy = _enemies_in_range[0]
		var direction = (target_enemy.global_position - global_position).normalized()
		rotation = direction.angle()
		rotation = wrapf(rotation, -PI/2, 3*PI/2)
		

func _on_base_weapon_area_entered(area: Area2D) -> void:
#	if area.get_parent().is_in_group("Enemies") and area.global_position.distance_to(global_position) <= targeting_range:
		_enemies_in_range.append(area)

func _on_base_weapon_area_exited(area: Area2D) -> void:
#	if area.get_parent().is_in_group("Enemies"):
		_enemies_in_range.erase(area)

func _on_fire_rate_timer_timeout() -> void:
	if not _enemies_in_range.is_empty():
		spawn_bullet()
		if ammo <= 0:
			reload()
