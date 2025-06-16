extends Node

const MenuScene = "uid://c2gocuhw2o7py"
const SettingsScene = "uid://dp42fom7cc3n0"
const LoadedCurrencyScene = preload("uid://do1wux8nsle53")

const SETTINGS_RES_PATH: String = "user://settings.tres"
const RESEARCH_TEXTURE = "assets/sprites/currency.png"

#region global_game_specific_variables

var price_multiplier: float = 0.5
var price_increase_rate: float = 0.07

var highest_game_time: float = 0.0

## If screen is being touched, then use this direction
var movement_joystick_direction : Vector2 = Vector2.ZERO

var shooting_joystick_direction : Vector2 = Vector2.ZERO

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


#var current_level: int = 1
var is_game_paused: bool = false
var is_game_over: bool = false
var is_in_shop : bool = false


# Inventory and items
#var inventory: Dictionary = {}
#var collected_augments: Array = []

# Checkpoint and respawn
#var last_savepoint: Vector2 = Vector2.ZERO
#var respawn_position: Vector2 = Vector2.ZERO

var player_reload_speed_mult : float
var player_health_mult : float
var upgrade_shop_spawn_divisor : float = 5


#endregion

func powerup_collected(powerup_type: int) -> void:
	powerups[powerup_type] += 1
	#world.hud.update_hud_buttons()
	
func get_currency_bbcode() -> String:
	return "[img=40px]%s[/img]" % RESEARCH_TEXTURE


func apply_augment(augment: AugmentsData) -> void:
	for stat:StatModifier in augment.stats_to_modify:
		CharacterStats.modify_stat(stat.key, stat.operation, stat.value)


func update_highest_game_time(time: float) -> void:
	if time > highest_game_time:
		highest_game_time = time


# Methods for managing game state
func reset_game() -> void:
	price_multiplier = 0
	price_increase_rate = 0.07
	
	#current_level = 1
	#is_game_paused = false
	#is_game_over = false
	#inventory.clear()
	#collected_items.clear()
	#last_checkpoint = Vector2.ZERO
	#respawn_position = Vector2.ZERO
	 #Reinitialize the player?



#region Saving and loading
#NOTE: To be done at the during the last phase of dev.
func save_game() -> void:
		# Implement saving game state to a file or database
	pass

func load_game() -> void:
		# Implement loading game state from a file or database
	pass
	

#Use a initial resource with all initial values and reset to that...? No that is for save reset... Just delete save file lul

static var unlocked_guns: Dictionary = {}  # gun_name: bool
var all_possible_guns : Dictionary

func unlock_gun(gun: GunData) -> void:
	gun.unlocked = true
	#TODO: save_unlocked_guns()

func emit_research_points(enemy_position: Vector2, research_point_drops: int) -> void:
	for i in research_point_drops:
		var drop: CurrencyDrop = LoadedCurrencyScene.instantiate()
		drop.global_position = enemy_position
		RunData.world.add_child.call_deferred(drop)

#endregion
