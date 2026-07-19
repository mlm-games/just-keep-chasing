class_name EnemySpawner extends Node

const MAX_SPAWN_ATTEMPTS := 10


static func spawn_enemy(enemy_data: EnemyData, position: Vector2) -> BaseEnemy:
	if not enemy_data:
		push_error("EnemySpawner: enemy_data is null")
		return null
	
	if not enemy_data.base_enemy_scene:
		push_error("EnemySpawner: EnemyData is missing a base scene: " + str(enemy_data.resource_path))
		return null
	
	var enemy_instance: BaseEnemy = enemy_data.base_enemy_scene.instantiate()
	
	# Duplicate the data to avoid shared state issues
	var data_copy = enemy_data.duplicate_with_res_name()
	data_copy.resource_name = CollectionManager.get_resource_name(enemy_data)
	
	enemy_instance.enemy_data_resource = data_copy
	enemy_instance.global_position = position
	
	return enemy_instance


static func get_random_by_spawn_chance() -> EnemyData:
	if RunData.spawnable_enemies.is_empty():
		push_warning("EnemySpawner: No spawnable enemies available")
		return null

	var spawn_range = RunData.enemy_spawn_type_range
	var candidates: Array[EnemyData] = []

	for spawn_order in RunData.spawnable_enemies.keys():
		if spawn_order >= spawn_range.x and spawn_order <= spawn_range.y:
			var bucket = RunData.spawnable_enemies[spawn_order]
			if bucket is Array:
				for e in bucket:
					if e is EnemyData:
						candidates.append(e)
			elif bucket is EnemyData:
				candidates.append(bucket)

	if candidates.is_empty():
		push_warning("EnemySpawner: No enemies in current spawn range")
		return null

	for _attempt in range(MAX_SPAWN_ATTEMPTS):
		var enemy_data: EnemyData = candidates.pick_random()
		if enemy_data and randf() <= enemy_data.enemy_spawn_chance:
			return enemy_data

	return candidates.pick_random()
