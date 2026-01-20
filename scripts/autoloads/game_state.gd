extends Node

const MenuScene = "uid://c2gocuhw2o7py"
const SettingsScene = "uid://dp42fom7cc3n0"
const SETTINGS_RES_PATH: String = "user://settings.tres"
const RESEARCH_TEXTURE = "assets/sprites/currency.png"

#region Global Game Variables

var highest_game_time: float = 0.0
var shooting_joystick_direction: Vector2 = Vector2.ZERO

enum StatusEffectType {
	FIRE,
	POISON,
	BLIGHT,
	LEECH,
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

## The problem with this is parallel states.. 
#enum GameState {
	#RUNNING,
	#PAUSED,
	#IN_SHOP,
	#GAME_OVER,
	#MENU
#}

var is_game_paused: bool = false
var is_game_over: bool = false

var player_reload_speed_mult: float = 1.0
var player_health_mult: float = 1.0

#endregion

#region Unlocks

var unlocked_guns: Dictionary[StringName, GunData] = {}
var unlocked_enemies: Dictionary[StringName, EnemyData] = {}
var unlocked_augments: Dictionary[StringName, AugmentsData] = {}

#endregion


func get_currency_bbcode() -> String:
	return "[img=40px]%s[/img]" % RESEARCH_TEXTURE


func apply_augment(augment: AugmentsData) -> void:
	if not augment:
		return
	
	for stat: StatModifier in augment.stats_to_modify:
		CharacterStats.modify_stat(stat.key, stat.operation, stat.value)


func update_highest_game_time(time: float) -> void:
	if time > highest_game_time:
		highest_game_time = time


func update_achievements() -> void:
	for achievement in BasicAchievements.get_all_achievements():
		if achievement.is_active and not achievement.stat_key.is_empty():
			var stat_value = CountStats.get_stat(achievement.stat_key)
			if stat_value != null:
				BasicAchievements.update_achievement(achievement.title.to_snake_case(), stat_value)


#region Gun Unlock System

func unlock_gun(gun: GunData) -> void:
	if not gun:
		return
	
	var gun_name = CollectionManager.get_resource_name(gun)
	
	CountStats._all_stats.unlocked_guns[gun_name] = true
	
	var collection_gun = CollectionManager.all_guns.get(gun_name)
	if collection_gun:
		collection_gun.unlocked = true
	
	unlocked_guns[gun_name] = gun
	
	print("Unlocked gun: %s" % gun_name)


func is_gun_unlocked(gun_path_or_name: String) -> bool:
	var gun_name = gun_path_or_name.get_file().trim_suffix(".tres")
	return unlocked_guns.has(gun_name)

#endregion

#region Save/Load

func save_game() -> void:
	# TODO: Implement saving game state
	pass


func load_game() -> void:
	# TODO: Implement loading game state
	pass
	

#endregion
