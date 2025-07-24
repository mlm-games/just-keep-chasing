class_name EnemySpawner extends Node

static func spawn_enemy(enemy_data: EnemyData, position: Vector2) -> Node2D:
	if not enemy_data.base_enemy_scene:
		push_error("EnemyData is missing a base scene: " + enemy_data.resource_path)
		return null
		
	var enemy_instance : BaseEnemy = PoolManager.get_pool(enemy_data.base_enemy_scene).get_object()
	# The enemy's own _ready function handles the application of data.
	enemy_instance.enemy_data_resource = enemy_data.duplicate_with_res_name()
	enemy_instance.enemy_data_resource.resource_name = CollectionManager.get_resource_name(enemy_data)
	enemy_instance.global_position = position
	return enemy_instance


static func get_random_by_spawn_chance() -> EnemyData:
	#TODO: Replace randfs in the powertype scene or script (as a static fn?) itself or implement a better version
	var enemy_data: EnemyData = RunData.spawnable_enemies[randi_range(RunData.enemy_spawn_type_range.x, RunData.enemy_spawn_type_range.y)]
	if enemy_data.enemy_spawn_chance < randf():
		enemy_data = get_random_by_spawn_chance()
	return enemy_data
