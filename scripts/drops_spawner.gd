class_name DropsSpawner

static var _drop_pool = ObjectPool.new(LoadedCurrencyScene, 50, 500)

const LoadedCurrencyScene = preload("uid://do1wux8nsle53")

static func emit_mito_energy(enemy_position: Vector2, mito_energy_drops: int) -> void:
	for i in mito_energy_drops:
		var drop: CurrencyDrop = _drop_pool.get_object()
		drop.global_position = enemy_position
		#drop.reparent(World.I)
