extends Sprite2D

@export var boundary_size := 90.0

var start_point : Vector2
var target_point : Vector2


func _assign_start_point(point : Vector2) -> void:
	start_point = point
	show()
	position = start_point


func _update_target_point(point : Vector2) -> void:
	var distance : float = clamp(
		start_point.distance_to(point),
		0.0,
		boundary_size
		)
	var direction : Vector2 = start_point.direction_to(point)
	target_point = direction * distance
	%Stick.set_position(target_point)
