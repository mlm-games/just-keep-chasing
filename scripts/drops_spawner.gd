class_name DropsSpawner

const LoadedCurrencyScene = preload("uid://do1wux8nsle53")

static func emit_mito_energy(enemy_position: Vector2, mito_energy_drops: int) -> void:
	for i in mito_energy_drops:
		var drop: CurrencyDrop = LoadedCurrencyScene.instantiate()
		drop.global_position = enemy_position
		RunData.world.add_child.call_deferred(drop)
