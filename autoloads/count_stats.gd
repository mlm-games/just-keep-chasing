extends Node


 
var total_count_stats : Dictionary[StringName, int] = {
	"damage_dealt": 0,
	"damage_taken": 0,
	"enemies_killed": 0,
	"powerups_used": 0,
	"games_won": 0,
	"games_played": 0,
	"health_healed": 0,
	"essence_collected": 0,
	"longest_run_time": 0,
	"bullets_fired": 0
}

var powerup_collection_stats: Dictionary[PowerupData, int] = {}

var enemies_type_killed_stats : Dictionary[EnemyData, int] = {}

var guns_fired_by_type_stats : Dictionary[GunData, int] = {}

var augment_items_collection_stats : Dictionary[Augments, int] = {}


func increment_stat(stat_name: Variant, amount: int = 1, stat_dict: Dictionary = total_count_stats) -> void:
	if stat_dict.has(stat_name):
		stat_dict[stat_name] += amount
		stat_updated.emit(stat_name, stat_dict[stat_name])

signal stat_updated(stat_name: String, new_value: int)

func get_stat(stat_key: Variant) -> int:
	if stat_key is String:
		return total_count_stats.get(stat_key, 0)
	elif stat_key is PowerupData:
		return powerup_collection_stats.get(stat_key, 0)
	elif stat_key is Augments:
		return augment_items_collection_stats.get(stat_key, 0)
	elif stat_key is GunData:
		return guns_fired_by_type_stats.get(stat_key, 0)
	else:
		return enemies_type_killed_stats.get(stat_key, 0)





func _ready() -> void:
	_init_dicts()

## Auto adds the keys instead of manually having to change them everytime
func _init_dicts() -> void:
	for enemy_type:EnemyData in GameState.collection_res.enemies.values():
		enemies_type_killed_stats.get_or_add(enemy_type, 0)
	
	for gun_type:GunData in GameState.collection_res.guns.values():
		guns_fired_by_type_stats.get_or_add(gun_type, 0)
	
	for augment:Augments in GameState.collection_res.augments.values():
		augment_items_collection_stats.get_or_add(augment, 0)
	
	for powerup_type:PowerupData in GameState.collection_res.powerups.values():
		powerup_collection_stats.get_or_add(powerup_type, 0)

func save():
	var save_stats : = total_count_stats.duplicate(true)
	
