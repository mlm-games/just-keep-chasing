class_name PickUp
extends Area2D

signal picked_up()

var collected_by: Player

var _current_speed: = 500.0

# Have to use data models
@onready var sprite 

func _ready() -> void:
	monitorable = false

func set_texture(texture: Resource) -> void:
	if sprite != null:
		sprite.texture = texture

func _physics_process(delta: float) -> void:
	if collected_by != null:
		global_position = global_position.move_toward(collected_by.global_position, delta * _current_speed)
		_current_speed += 20

func pickup() -> void:
	picked_up.emit()
	queue_free()
