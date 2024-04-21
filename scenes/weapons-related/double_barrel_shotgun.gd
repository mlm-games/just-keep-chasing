class_name DoubleBarrelShotgun extends Shotgun

func _ready() -> void:
	pellet_damage = 3
	pellets_per_shot = 7
	gun_capacity = 2
	pellet_spread = 15
	super._ready()
	bullets_fired = gun_capacity



func get_targets_in_range() -> Array:
	var targets = []
	var objects = get_tree().get_nodes_in_group("On Screen Enemies")
	for object in objects:
		if object.global_position.distance_to(global_position) <= shooting_range:
			targets.append(object)
	return targets
