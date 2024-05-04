class_name BaseWeapon extends Area2D

@export var bullet: PackedScene
@export var reload_time: float = 1.0
@export var max_ammo: int = 10
@export var ammo: int = max_ammo
@export var targeting_range: float = 500.0

@onready var _bullet_spawn_point: Marker2D = %BulletSpawnPoint
@onready var _reload_timer: Timer = %ReloadTimer

var _enemies_in_range: Array = []

func _ready() -> void:
	_reload_timer.wait_time = reload_time
	_reload_timer.one_shot = true
	_reload_timer.connect("timeout", _on_reload_timer_timeout)

func _physics_process(_delta: float) -> void:
	if not _enemies_in_range.is_empty():
		aim_at_enemy()

func spawn_bullet() -> void:
	if ammo > 0:
		var bullet_instance = bullet.instance()
		bullet_instance.global_position = _bullet_spawn_point.global_position
		bullet_instance.global_rotation = _bullet_spawn_point.global_rotation
		get_tree().current_scene.add_child(bullet_instance)
		ammo -= 1
		if ammo == 0:
			reload()

func reload() -> void:
	if not _reload_timer.is_stopped():
		return
	_reload_timer.start()

func _on_reload_timer_timeout() -> void:
	ammo = max_ammo

func aim_at_enemy() -> void:
	if not _enemies_in_range.is_empty():
		var target_enemy = _enemies_in_range[0]
		var direction = (target_enemy.global_position - global_position).normalized()
		rotation = direction.angle()

func _on_BaseWeapon_body_entered(body: Node) -> void:
	if body.is_in_group("enemies") and body.global_position.distance_to(global_position) <= targeting_range:
		_enemies_in_range.append(body)

func _on_BaseWeapon_body_exited(body: Node) -> void:
	if body.is_in_group("enemies"):
		_enemies_in_range.erase(body)
