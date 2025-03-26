extends Node

const SAVE_FILE_PATH = "user://count_stats.save"
 
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

var powerup_collection_stats : Dictionary[PowerupData, int] = {}
var enemies_type_killed_stats : Dictionary[EnemyData, int] = {}
var guns_fired_by_type_stats : Dictionary[GunData, int] = {}
var augment_items_collection_stats : Dictionary[Augments, int] = {}


func _ready() -> void:
	_init_dicts()
	load_stats()

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

func increment_stat(stat_key: Variant, amount: int = 1, stat_dict: Dictionary = total_count_stats) -> void:
	if stat_dict.has(stat_key):
		stat_dict[stat_key] += amount
		stat_updated.emit(stat_key, stat_dict[stat_key])
		
		save_stats()

signal stat_updated(stat_key: String, new_value: int)

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

func save_stats() -> void:
	var save_data := {
		"total_count_stats": total_count_stats.duplicate(true),
		"powerup_stats": _serialize_resource_dict(powerup_collection_stats),
		"enemy_stats": _serialize_resource_dict(enemies_type_killed_stats),
		"gun_stats": _serialize_resource_dict(guns_fired_by_type_stats),
		"augment_stats": _serialize_resource_dict(augment_items_collection_stats)
	}
	
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if file: file.store_var(save_data); file = null # Deinit
	else:
		push_error("Failed to save stats data: " + str(FileAccess.get_open_error()))


func load_stats() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		return
	
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if file:
		var data : Variant = file.get_var()
		file = null
			
		if data is Dictionary:
			var loaded_stats : Dictionary[StringName, int] = data["total_count_stats"]
			for key:String in loaded_stats:
					if total_count_stats.has(key):
							total_count_stats[key] = loaded_stats[key]
			
			# Load resource-based stats
			_deserialize_resource_dict(data.get("powerup_stats", {}), powerup_collection_stats, GameState.collection_res.powerups)
			_deserialize_resource_dict(data.get("enemy_stats", {}), enemies_type_killed_stats, GameState.collection_res.enemies)
			_deserialize_resource_dict(data.get("gun_stats", {}), guns_fired_by_type_stats, GameState.collection_res.guns)
			_deserialize_resource_dict(data.get("augment_stats", {}), augment_items_collection_stats, GameState.collection_res.augments)
	else:
			push_error("Failed to load stats data: " + str(FileAccess.get_open_error()))


static func _serialize_resource_dict(resource_dict: Dictionary) -> Dictionary:
	var serialized := {}
	
	for resource:BaseData in resource_dict:
			serialized[ResourceLoader.get_resource_uid(resource.resource_path)] = resource_dict[resource]
			#print(ResourceUID.id_to_text(ResourceLoader.get_resource_uid(resource.resource_path)))
	return serialized

static func _deserialize_resource_dict(serialized_dict: Dictionary, target_dict: Dictionary, resource_collection: Dictionary) -> void:
	for resource_uid_int in serialized_dict:
		for resource:Resource in resource_collection.values():
			
			if ResourceLoader.get_resource_uid(resource.resource_path) == resource_uid_int:
				target_dict[resource] = serialized_dict[resource_uid_int]
				break
			else:
				printerr("Hi, click here for a suprise **")

func update_longest_run_time(current_time: int) -> void:
	if current_time > total_count_stats["longest_run_time"]:
		total_count_stats["longest_run_time"] = current_time
		stat_updated.emit("longest_run_time", current_time)
		save_stats()
