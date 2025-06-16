extends Node
## A read-only database of all game content (items, enemies, etc.).
## Loads everything once at the start of the game.

const COLLECTION_RESOURCE_PATH = "res://resources/collection_resource.tres"

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
