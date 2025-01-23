extends Node

#TODO: change out some lines for applying settings on restart and showing a label saying require restart
#TODO: Make the settings load on menu scene

const MenuScene = "res://scenes/UI/menu.tscn"
const SettingsScene = "res://scenes/UI/settings.tscn"

const AUGMENTS_DIR : String = "res://resources/augments/"
const POWERUPS_DIR : String = "res://resources/powerups/"
const CONFIG_DIR: String = "data/saves/"
const BASE_DIR: String = "user://"
const CONFIG_PATH: String = BASE_DIR + CONFIG_DIR + "settings.tres"

#region global_game_specific_variables

var augments : Array[Augments]
var powerups_data: Array[PowerupData]

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

enum Stats {
	MAX_HEALTH,
	HEALTH,
	SPEED,
	DAMAGE_MULT,
	DAMAGE,
	RELOAD_SPEED_REDUCTION_MULT,
	TARGETTING_RANGE_MULT,
	SHOP_COST_REDUCTION_MULT,
	RAW_AMMO_INC,
	AMMO_INC_MULT,
	HEALTH_REGEN,
	FLAT_ENEMY_HEALTH_REDUCTION,
	ENEMY_HEALTH_REDUCTION_MULT,
	FIRE_SPEED_REDUCTION_MULT,
}

# Making the firespeed go very fast when health goes below 20%
# Other effects from my browser
# Can do this after all the polish and marketing stuff...
enum Effects {
	
}

enum Operation {
	ADD,
	MULTIPLY,
	REPLACE,
	EXPONENTIAL,
}

var player_stats: Dictionary = {
	Stats.MAX_HEALTH: 100,
	Stats.SPEED: 250,
	Stats.DAMAGE_MULT: 1,
	Stats.DAMAGE: 0,
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
var upgrade_shop_spawn_divisor : int = 20


#endregion

#region settings_variables

#func _process(delta: float) -> void:
	#print(Engine.get_frames_per_second(), Engine.max_fps)
#	Save file information
var first_time_setup: bool = true
var accessibility: Dictionary = {
	"current_locale": "en",
	"small_text_font_size": 20,
	"big_text_font_size": 64
}
var gameplay_options: Dictionary = {
	"max_fps": 60,
	"pause_on_lost_focus": true
}
var video: Dictionary = {
	"borderless": false,
	"fullscreen": false,
	"resolution": Vector2i(1080, 720)
}
var audio: Dictionary = {
	"Master": 100,
	"Music": 100,
	"SFX": 100
}
#endregion

func  _ready() -> void:
	augments = populate_augments()
	powerups_data = populate_powerup_data()
	load_settings(true)

func populate_augments() -> Array[Augments]:
	var dir : DirAccess = DirAccess.open(AUGMENTS_DIR)
	var augments_arr : Array[Augments]
	for res:String in dir.get_files():
		if res.ends_with(".tres"):
			augments_arr.append(ResourceLoader.load(AUGMENTS_DIR + res))
	return augments_arr

func populate_powerup_data() -> Array[PowerupData]:
	var dir : DirAccess = DirAccess.open(POWERUPS_DIR)
	var powerup_data_list : Array[PowerupData]
	for res:String in dir.get_files():
		if res.ends_with(".tres"):
			powerup_data_list.append(ResourceLoader.load(POWERUPS_DIR + res))
	return powerup_data_list

func powerup_collected(powerup_type: int) -> void:
	powerups[powerup_type] += 1
	get_node("/root/World/HUD").update_hud()

func apply_augment(augment: Augments) -> void:
	for stat:StatsModifier in augment.stats_to_modify:
		if stat.key in player_stats.keys():
			match stat.operation:
				Operation.REPLACE:
					player_stats[stat.key] = stat.value
				Operation.ADD:
					player_stats[stat.key] += stat.value
				Operation.MULTIPLY:
					player_stats[stat.key] *= stat.value
				Operation.EXPONENTIAL:
					player_stats[stat.key] = pow(player_stats[stat.key], stat.value)
			if stat.key == Stats.MAX_HEALTH:
				#Update max_health in player's health component
				get_tree().get_nodes_in_group("Player")[0].update_max_health(player_stats[Stats.MAX_HEALTH])
		else:
			match stat.key:
				Stats.HEALTH:
					get_tree().get_nodes_in_group("Player")[0].health_component.heal_or_damage(20)

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

func get_or_create_dir(path: String) -> DirAccess:
	var dir := DirAccess.open(BASE_DIR)
	if !dir.dir_exists(path):
		dir.make_dir_recursive(path)
	return dir

func save_settings() -> void:
	var new_save := GameSettingsSave.new()
	new_save.first_time_setup = first_time_setup
	new_save.accessibility = accessibility.duplicate(true)
	new_save.gameplay_options = gameplay_options.duplicate(true)
	new_save.video = video.duplicate(true)
	new_save.audio = audio.duplicate(true)
	
	get_or_create_dir(CONFIG_DIR)
	var save_result := ResourceSaver.save(new_save, CONFIG_PATH)
	
	if save_result != OK:
		push_error("Failed to save settings to: %s" % CONFIG_PATH)
	else:
		print("Settings successfully saved to: %s" % CONFIG_PATH)

func load_settings(with_ui_update : bool = false) -> bool:
	if !ResourceLoader.exists(CONFIG_PATH):
		print("Settings save file not found.")
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

#endregion
