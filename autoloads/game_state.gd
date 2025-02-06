extends Node

const MenuScene = "res://scenes/UI/menu.tscn"
const SettingsScene = "res://scenes/UI/settings.tscn"

const AUGMENTS_DIR : String = "res://resources/augments/"
const POWERUPS_DIR : String = "res://resources/powerups/"
const ENEMY_DATA_DIR : String = "res://resources/enemies/"
const GUN_DATA_DIR : String = "res://resources/guns/"
const CONFIG_PATH: String ="user://settings.tres"
const RESEARCH_TEXTURE = "assets/sprites/currency.png"

var collection_res : CollectionResource = CollectionResource.new()

#region global_game_specific_variables

var price_multiplier: float = 1.0
var price_increase_rate: float = 0.05  # Increase by 10% each time

var highest_game_time: float = 0.0

enum PowerupType {
	SLOW_TIME,
	SCREEN_BLAST,
	HEAL,
	INVINCIBLE,
}

enum StatusEffectType {
	FIRE,
	POISON,
	BLIGHT,
	LEECH,
}

var powerups := {
	PowerupType.SLOW_TIME: 0,
	PowerupType.SCREEN_BLAST: 0,
	PowerupType.HEAL: 0,
	PowerupType.INVINCIBLE: 0,
}

# Making the firespeed go very fast when health goes below 20%
# Other effects from my browser
# Can do this after all the polish and marketing stuff...
enum Effects {
	 
}

# Player-related properties
#var player_lives: int = 1

# Game-related properties
var research_points : int = 0
#var current_level: int = 1
var is_game_paused: bool = false
var is_game_over: bool = false

# Inventory and items
#var inventory: Dictionary = {}
#var collected_augments: Array = []

# Checkpoint and respawn
#var last_savepoint: Vector2 = Vector2.ZERO
#var respawn_position: Vector2 = Vector2.ZERO

var player_reload_speed_mult : float
var player_health_mult : float
var upgrade_shop_spawn_divisor : float = 20


#endregion

#region settings_variables

#func _process(delta: float) -> void:
	#print(Engine.get_frames_per_second(), Engine.max_fps)
#	Save file information
var first_time_setup: bool = true
var accessibility: Dictionary = {
	"current_locale": "en",
	"small_text_font_size": 20,
	"big_text_font_size": 64,
}
var gameplay_options: Dictionary = {
	"max_fps": 60,
	"pause_on_lost_focus": true,
}
var video: Dictionary = {
	"borderless": false,
	"fullscreen": true,
	"resolution": Vector2i(1080, 720),
}
var audio: Dictionary = {
	"Master": 100,
	"Music": 100,
	"SFX": 100,
}
#endregion

func  _ready() -> void:
	if OS.has_feature("editor"):
		collection_res.augments = get_resource_paths_in_directory(AUGMENTS_DIR)
		collection_res.powerups = get_resource_paths_in_directory(POWERUPS_DIR)
		collection_res.enemies = get_resource_paths_in_directory(ENEMY_DATA_DIR)
		collection_res.guns = get_resource_paths_in_directory(GUN_DATA_DIR)
		print(ResourceSaver.save(collection_res, "res://resources/collection_resource.tres"))
	if collection_res.augments.is_empty():
		collection_res = load("res://resources/collection_resource.tres")

func get_resource_paths_in_directory(resources_dir: String, load_resource_paths: bool = false) -> Dictionary[StringName, Variant]:
	var dir : DirAccess = DirAccess.open(resources_dir)
	var res_list : Dictionary[StringName, Variant] = {}
	if load_resource_paths:
		for res:String in dir.get_files():
			if res.ends_with(".tres"):
				res_list.get_or_add(res.trim_suffix(".tres"),resources_dir + res)
	else:
		for res:String in dir.get_files():
			if res.ends_with(".tres"):
				var loaded_res = load(resources_dir + res)
				loaded_res.id = res.trim_suffix(".tres")
				res_list.get_or_add(res.trim_suffix(".tres"), loaded_res)
	return res_list

func powerup_collected(powerup_type: int) -> void:
	powerups[powerup_type] += 1
	get_node("/root/World/HUD").update_hud()
	
func get_currency_bbcode() -> String:
	return "[img=40px]%s[/img]" % RESEARCH_TEXTURE




func apply_augment(augment: Augments) -> void:
	for stat:StatModifier in augment.stats_to_modify:
		GameStats.modify_stat(stat.key, stat.operation, stat.value)


func update_highest_game_time(time: float) -> void:
	if time > highest_game_time:
		highest_game_time = time


# Methods for managing game state
#func reset_game() -> void:
	#research_points = 0
	#current_level = 1
	#is_game_paused = false
	#is_game_over = false
	#inventory.clear()
	#collected_items.clear()
	#last_checkpoint = Vector2.ZERO
	#respawn_position = Vector2.ZERO
	# Reinitialize the player?

#
#func add_to_inventory(item: String, quantity: int = 1) -> void:
	#if inventory.has(item):
		#inventory[item] += quantity
	#else:
		#inventory[item] = quantity
#
#func remove_from_inventory(item: String, quantity: int = 1) -> void:
	#if inventory.has(item):
		#inventory[item] -= quantity
		#if inventory[item] <= 0:
			#inventory.erase(item)
#
#func collect_item(item: String) -> void:
	#if not collected_items.has(item):
		#collected_items.append(item)
#
#func has_collected_item(item: String) -> bool:
	#return collected_items.has(item)
#
#func set_checkpoint(position: Vector2) -> void:
	#last_checkpoint = position



#region Saving and loading

func save_game() -> void:
		# Implement saving game state to a file or database
	pass

func load_game() -> void:
		# Implement loading game state from a file or database
	pass

func respawn_player() -> void:
		# Implement respawning the player at the last checkpoint or respawn position
	pass

#func get_or_create_dir(path: String) -> DirAccess:
	#var dir := DirAccess.open(BASE_DIR)
	#if !dir.dir_exists(path):
		#dir.make_dir_recursive(path)
	#return dir
	
func save_settings() -> void:
	var new_save := GameSettingsSave.new()
	new_save.first_time_setup = first_time_setup
	new_save.accessibility = accessibility.duplicate(true)
	new_save.gameplay_options = gameplay_options.duplicate(true)
	new_save.video = video.duplicate(true)
	new_save.audio = audio.duplicate(true)
	
	#get_or_create_dir(CONFIG_DIR)
	var save_result := ResourceSaver.save(new_save, CONFIG_PATH)
	
	if save_result != OK:
		push_error("Failed to save settings to: %s" % CONFIG_PATH)
	else:
		print("Settings successfully saved to: %s" % CONFIG_PATH)

func load_settings(with_ui_update : bool = false) -> bool:
	if !ResourceLoader.exists(CONFIG_PATH):
		print("Settings save file not found.")
		if with_ui_update == true:
			var settings_instance = load(SettingsScene).instantiate()
			add_child(settings_instance)
			#await settings_instance.sign
			remove_child(settings_instance)
			settings_instance.queue_free()
		return false
	
	print("Settings file was found.")
	var new_load: GameSettingsSave = ResourceLoader.load(CONFIG_PATH, "Resource", ResourceLoader.CACHE_MODE_REUSE)
	
	if new_load == null:
		push_error("Failed to load settings from: %s" % CONFIG_PATH)
		return false
	
	first_time_setup = new_load.first_time_setup
	accessibility = new_load.accessibility.duplicate(true)
	gameplay_options = new_load.gameplay_options.duplicate(true)
	video = new_load.video.duplicate(true)
	audio = new_load.audio.duplicate(true)
	
	if with_ui_update == true:
		var settings_instance = load(SettingsScene).instantiate()
		add_child(settings_instance)
		#await settings_instance.sign
		remove_child(settings_instance)
		settings_instance.queue_free()
	
	return true
#Use a initial resource with all initial values and reset to that...? No that is for save reset... Just delete save file lul
func reset_stats() -> void:
	research_points = 0
	price_multiplier = 1

var unlocked_guns: Dictionary = {}  # gun_name: bool
var all_possible_guns

func unlock_gun(gun: GunData) -> void:
	gun.unlocked = true
	save_unlocked_guns()

#func is_gun_unlocked(gun: BaseGun) -> bool:
	#return gun.unlocked

func save_unlocked_guns() -> void:
	# Save to file system
	pass

func load_unlocked_guns() -> void:
	# Load from file system
	pass



#endregion
