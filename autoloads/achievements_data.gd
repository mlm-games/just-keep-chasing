class_name Achievement extends Resource

static var achievements := {
	"damage_dealer": {
		"name": "Damage Dealer",
		"description": "Deal 10000 total damage",
		"is_secret": false,
		"count_goal": 10000,
		"current_progress": 0,
		"icon_path": "res://assets/achievements/damage_dealer.png",
		"unlocked": false,
		"active": true,
		"stat_key": "damage_dealt",
		"reward": "Unlocks weapon: Sawed off shotgun"
	},
	"mass_destroyer": {
		"name": "Mass Destroyer",
		"description": "Kill 1000 enemies",
		"is_secret": false,
		"count_goal": 1000,
		"current_progress": 0,
		"icon_path": "res://assets/achievements/mass_destroyer.png",
		"unlocked": false,
		"active": true,
		"stat_key": "enemies_killed",
		"reward": "Unlocks enemy: Straight liner"
	},
	"power_user": {
		"name": "Power User",
		"description": "Use 100 powerups",
		"is_secret": false,
		"count_goal": 100,
		"current_progress": 0,
		"icon_path": "res://assets/achievements/power_user.png",
		"unlocked": false,
		"active": true,
		"stat_key": "powerups_used",
		"reward": "Highly increase star powerup drop chance"
	},
	"speed_demon": {
		"name": "Speed Demon",
		"description": "Use slow time ability 50 times",
		"is_secret": false,
		"count_goal": 50,
		"current_progress": 0,
		"icon_path": "res://assets/achievements/speed_demon.png",
		"unlocked": false,
		"active": true,
		"stat_key": preload("uid://co1l4ykdh5yer"),
		"reward": "Increases player speed by 10%"
	},
	"nuclear_option": {
		"name": "Nuclear Option",
		"description": "Use screen blast 25 times",
		"is_secret": false,
		"count_goal": 25,
		"current_progress": 0,
		"icon_path": "res://assets/achievements/nuclear_option.png",
		"unlocked": false,
		"active": true,
		"stat_key": preload("uid://ff18iggvak6h"),
		"reward": "Increases screen blast radius by 20%"
	},
	"survivor": {
		"name": "Survivor",
		"description": "Win 10 games",
		"is_secret": false,
		"count_goal": 10,
		"current_progress": 0,
		"icon_path": "res://assets/achievements/survivor.png",
		"unlocked": false,
		"active": true,
		"stat_key": "games_won",
		"reward": "Unlocks new character skin"
	},
	"battle_hardened": {
		"name": "Battle Hardened",
		"description": "Play 50 games",
		"is_secret": false,
		"count_goal": 50,
		"current_progress": 0,
		"icon_path": "res://assets/achievements/battle_hardened.png",
		"unlocked": false,
		"active": true,
		"stat_key": "games_played",
		"reward": "Increases max health by 10%"
	},
	"medic": {
		"name": "Medic",
		"description": "Use healing powerup 30 times",
		"is_secret": false,
		"count_goal": 30,
		"current_progress": 0,
		"icon_path": "res://assets/achievements/medic.png",
		"unlocked": false,
		"active": true,
		"stat_key": "heal_used",
		"reward": "Increases healing multiplier by 15%"
	},
	"untouchable": {
		"name": "Untouchable",
		"description": "Use invincibility powerup 20 times",
		"is_secret": false,
		"count_goal": 20,
		"current_progress": 0,
		"icon_path": "res://assets/achievements/untouchable.png",
		"unlocked": false,
		"active": true,
		"stat_key": preload("uid://cw5xlfwubk72c"),
		"reward": "Increases invincibility duration by 2 seconds"
	},
	"sharpshooter": {
		"name": "Sharpshooter",
		"description": "Achieve 90% targeting accuracy",
		"is_secret": true,
		"count_goal": 90,
		"current_progress": 0,
		"icon_path": "res://assets/achievements/sharpshooter.png",
		"unlocked": false,
		"active": true,
		"stat_key": "targeting_accuracy",
		"reward": "Increases targeting range by 25%"
	},
	"tank_buster": {
		"name": "Tank Buster",
		"description": "Deal 5000 damage to armored enemies",
		"is_secret": false,
		"count_goal": 5000,
		"current_progress": 0,
		"icon_path": "res://assets/achievements/tank_buster.png",
		"unlocked": false,
		"active": true,
		"stat_key": "armored_damage_dealt",
		"reward": "Increases raw damage modifier by 10"
	},
	"wealthy_collector": {
		"name": "Wealthy Collector",
		"description": "Collect 10000 currency",
		"is_secret": false,
		"count_goal": 10000,
		"current_progress": 0,
		"icon_path": "res://assets/achievements/wealthy_collector.png",
		"unlocked": false,
		"active": true,
		"stat_key": "currency_collected",
		"reward": "Increases currency pickup range by 50%"
	},
	"master_gunner": {
		"name": "Master Gunner",
		"description": "Fire 5000 bullets",
		"is_secret": false,
		"count_goal": 5000,
		"current_progress": 0,
		"icon_path": "res://assets/achievements/master_gunner.png",
		"unlocked": false,
		"active": true,
		"stat_key": "bullets_fired",
		"reward": "Reduces reload speed by 20%"
	}
}


var name: String
var description: String
var is_secret: bool
var count_goal: int
var current_progress: float
var icon_path: String
var unlocked: bool
var active: bool
var stat_key: Variant
var reward: String

func _init(p_name := "", p_description := "", p_is_secret := false, 
		   p_count_goal := 0, p_icon_path := "", p_active := true, p_stat_key := "", p_reward := "") -> void:
	name = p_name
	description = p_description
	is_secret = p_is_secret
	count_goal = p_count_goal
	current_progress = 0.0
	icon_path = p_icon_path
	unlocked = false
	active = p_active
	stat_key = p_stat_key
	reward = p_reward

func to_dict() -> Dictionary:
	return {
		"name": name,
		"description": description,
		"is_secret": is_secret,
		"count_goal": count_goal,
		"current_progress": current_progress,
		"icon_path": icon_path,
		"unlocked": unlocked,
		"active": active,
		"stat_key": stat_key,
		"reward": reward
	}
#TODO: A sound for reloading weapons
static func from_dict(dict: Dictionary) -> Achievement:
	var achievement := Achievement.new()
	achievement.name = dict.get("name", "")
	achievement.description = dict.get("description", "")
	achievement.is_secret = dict.get("is_secret", false)
	achievement.count_goal = dict.get("count_goal", 0)
	achievement.current_progress = dict.get("current_progress", 0.0)
	achievement.icon_path = dict.get("icon_path", "")
	achievement.unlocked = dict.get("unlocked", false)
	achievement.active = dict.get("active", true)
	achievement.stat_key = dict.get("stat_key", "")
	achievement.reward = dict.get("reward", "")
	return achievement
