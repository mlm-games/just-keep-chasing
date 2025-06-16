extends Node
## A read-only database of all game content (items, enemies, etc.).
## Loads everything once at the start of the game.

const COLLECTION_RESOURCE_PATH = "res://resources/collection_resource.tres"
const AUGMENTS_DIR : String = "res://resources/augments/"
const POWERUPS_DIR : String = "res://resources/powerups/"
const ENEMY_DATA_DIR : String = "res://resources/enemies/"
const GUN_DATA_DIR : String = "res://resources/guns/"

static var collection_res : CollectionResource = CollectionResource.new()

var all_enemies: Dictionary = {}
var all_augments: Dictionary = {}
var all_powerups: Dictionary = {}
var all_guns: Dictionary = {}

func _ready():
	var collection_res: CollectionResource = load(COLLECTION_RESOURCE_PATH)
	if not collection_res:
		push_error("Failed to load the main CollectionResource! Path: " + COLLECTION_RESOURCE_PATH)
		return
	
	all_enemies = collection_res.enemies
	all_augments = collection_res.augments
	all_powerups = collection_res.powerups
	all_guns = collection_res.guns
	
	print("CollectionManager loaded %d enemies, %d guns." % [all_enemies.size(), all_guns.size()])

#NOTE: For autoloading of data everytime a new one is added (took more time than making an entire game)
	if OS.has_feature("editor"):
		collection_res.augments = get_resource_paths_in_directory(AUGMENTS_DIR)
		collection_res.powerups = get_resource_paths_in_directory(POWERUPS_DIR)
		collection_res.enemies = get_resource_paths_in_directory(ENEMY_DATA_DIR)
		collection_res.guns = get_resource_paths_in_directory(GUN_DATA_DIR)
		print("Collection res save output:" + str(ResourceSaver.save(collection_res, "res://resources/collection_resource.tres")))
	if collection_res.augments.is_empty():
		collection_res = load("res://resources/collection_resource.tres")


static func get_resource_paths_in_directory(resources_dir: String, load_resource_paths: bool = false) -> Dictionary[StringName, Variant]:
	var dir : DirAccess = DirAccess.open(resources_dir)
	var res_list : Dictionary[StringName, Variant] = {}
	if load_resource_paths:
		for res:String in dir.get_files():
			if res.ends_with(".tres"):
				res_list.get_or_add(res.trim_suffix(".tres"),resources_dir + res)
	else:
		for res:String in dir.get_files():
			if res.ends_with(".tres"):
				var loaded_res : Resource = load(resources_dir + res)
				loaded_res.id = res.trim_suffix(".tres")
				res_list.get_or_add(res.trim_suffix(".tres"), loaded_res)
	return res_list

func get_enemy_dict_by_spawn_order() -> Dictionary[int, EnemyData]:
	var dict : Dictionary[int, EnemyData] = {}
	for enemy:EnemyData in all_enemies.values():
		dict.get_or_add(enemy.enemy_spawn_order, enemy)
	return dict
