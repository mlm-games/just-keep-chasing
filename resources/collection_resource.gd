class_name CollectionResource extends Resource

@export var enemies: Dictionary#[String, Array]
@export var augments: Dictionary
@export var powerups: Dictionary
@export var guns: Dictionary

func get_enemy_dict_by_key() -> Dictionary:
	var dict : Dictionary = {}
	for enemy:EnemyData in enemies.values():
		dict.get_or_add(enemy.enemy_spawn_order, enemy)
	return dict
