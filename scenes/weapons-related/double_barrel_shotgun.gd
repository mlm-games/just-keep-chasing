class_name DoubleBarrelShotgun extends Shotgun

func _ready() -> void:
	pellet_damage = 3
	pellets_per_shot = 5
	gun_capacity = 2
	pellet_spread = 15
	super._ready()
	pellets_fired = gun_capacity

func _on_area_entered(area: Area2D) -> void:
	enemies_in_range.append(area)
	if enemies_in_range.size() == 1:
		set_physics_process(true)

func _on_area_exited(area: Area2D) -> void:
	enemies_in_range.erase(area)
	if enemies_in_range.is_empty():
		set_physics_process(false)


