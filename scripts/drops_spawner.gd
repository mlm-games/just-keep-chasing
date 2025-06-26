class_name DropsSpawner

const LoadedCurrencyScene = preload("uid://do1wux8nsle53")

static func emit_research_points(enemy_position: Vector2, research_point_drops: int) -> void:
	for i in research_point_drops:
		var drop: CurrencyDrop = LoadedCurrencyScene.instantiate()
		drop.global_position = enemy_position
		RunData.world.add_child.call_deferred(drop)
