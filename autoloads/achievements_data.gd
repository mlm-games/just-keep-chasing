extends Node

var achievements = {
	"damage_dealer": {
		"name": tr("Damage Dealer"),
		"description": tr("Deal 10000 total damage"),
		"stat_name": "damage_dealt",
		"required_value": 10000,
		"condition": func(): return CountStats.get_stat("damage_dealt") >= 10000,
		"reward": tr("Unlocks weapon: Sawed off shotgun")
	},
	"mass_destroyer": {
		"name": tr("Mass Destroyer"),
		"description": tr("Kill 1000 enemies"),
		"stat_name": "enemies_killed",
		"required_value": 1000,
		"condition": func(): return CountStats.get_stat("enemies_killed") >= 1000,
		"reward": tr("Unlocks enemy: Straight liner")
	},
	"power_user": {
		"name": tr("Power User"),
		"description": tr("Use 100 powerups"),
		"stat_name": "powerups_used",
		"required_value": 100,
		"condition": func(): return CountStats.get_stat("powerups_used") >= 100,
		"reward": tr("Highly increase rainbow powerup drop chance")
	}
}

func check_achievement(achievement_id: String) -> bool:
	if achievements.has(achievement_id):
		return achievements[achievement_id].condition.call()
	return false
