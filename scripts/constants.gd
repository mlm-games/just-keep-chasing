class_name C #Constants

enum RARITY {
	COMMON,
	UNCOMMON,
	RARE,
	EPIC,
	LEGENDARY
}

# Rarity colors
const RARITY_COLORS: Dictionary = {
	0: Color.WHITE, # Common
	1: Color.GREEN, # Uncommon
	2: Color.BLUE,  # Rare
	3: Color.PURPLE, # Epic
	4: Color.ORANGE # Legendary
}

const STAT_NAMES = {
	CharacterStats.Stats.PLAYER_MAX_HEALTH: "Max Health",
	CharacterStats.Stats.PLAYER_HEALTH: "Current Health",
	CharacterStats.Stats.PLAYER_SPEED: "Movement Speed",
	CharacterStats.Stats.PLAYER_DAMAGE_MULT: "Damage Multiplier",
	CharacterStats.Stats.HEALING_MULT: "Healing Multiplier",
	CharacterStats.Stats.RAW_DAMAGE_MOD: "Flat Damage Bonus",
	CharacterStats.Stats.RELOAD_SPEED_REDUCTION_MULT: "Reload Speed Multiplier",
	CharacterStats.Stats.TARGETTING_RANGE_MULT: "Targeting Range Multiplier",
	CharacterStats.Stats.SHOP_COST_MULT: "Shop Cost Multiplier",
	CharacterStats.Stats.RAW_AMMO_INC: "Flat Ammo Increase",
	CharacterStats.Stats.AMMO_INC_MULT: "Ammo Multiplier",
	CharacterStats.Stats.HEALTH_REGEN: "Health Regeneration",
	CharacterStats.Stats.FLAT_ENEMY_HEALTH_REDUCTION: "Enemy Health Reduction",
	CharacterStats.Stats.ENEMY_HEALTH_MULT: "Enemy Health Multiplier",
	CharacterStats.Stats.ITEM_LEND_THRESHOLD: "Item Lend Threshold",
	CharacterStats.Stats.FIRE_SPEED_REDUCTION_MULT: "Fire Rate Multiplier",
	CharacterStats.Stats.GUN_ENEMY_DAMAGE_MULT: "Gun Enemy Damage Multiplier",
	CharacterStats.Stats.RAW_GUN_ENEMY_DAMAGE_REDUCTION: "Gun Enemy Damage Reduction",
	CharacterStats.Stats.GUN_ENEMY_TARGETTING_RANGE_MULT: "Gun Enemy Targeting Range Multiplier",
	CharacterStats.Stats.PLAYER_DAMAGE_REDUCTION: "Damage Reduction",
	CharacterStats.Stats.ENEMY_DAMAGE_REDUCTION: "Enemy Damage Reduction",
	CharacterStats.Stats.GUN_TARGETTING_SPEED: "Gun Targeting Speed",
	CharacterStats.Stats.POWERUP_PICKUP_RANGE: "Powerup Pickup Range",
	CharacterStats.Stats.CURRENCY_PICKUP_RANGE: "Currency Pickup Range",
	CharacterStats.Stats.DROP_VALUE_MULTIPLIER: "Drop Value Multiplier"
}


const OPERATION_VERBS = {
	CharacterStats.Operation.ADD: "Increases",
	CharacterStats.Operation.MULTIPLY: "Multiplies",
	CharacterStats.Operation.REPLACE: "Sets",
}


const COUNT_STAT_KEYS = {
	damage_dealt = "damage_dealt",
	damage_taken = "damage_taken",
	enemies_killed = "enemies_killed",
	powerups_used = "powerups_used",
	games_won = "games_won",
	games_played = "games_played",
	health_healed = "health_healed",
	mito_energy_collected = "mito_energy_collected",
	longest_run_time = "longest_run_time",
	bullets_fired = "bullets_fired",
}
