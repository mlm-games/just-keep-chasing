extends Node

signal stat_changed(stat_key: Stats, new_value: float)

class StatDefinition extends Resource:
	var base_value: float
	var current_value: float
	var min_value: float
	var max_value: float
	
	func _init(base: float, min_val: float = 0, max_val: float = INF) -> void:
		base_value = base
		current_value = base
		min_value = min_val
		max_value = max_val

enum Stats {
	PLAYER_MAX_HEALTH,
	PLAYER_HEALTH,
	PLAYER_SPEED,
	PLAYER_DAMAGE_MULT,
	HEALING_MULT,
	RAW_DAMAGE_MOD,
	RELOAD_SPEED_REDUCTION_MULT,
	TARGETTING_RANGE_MULT,
	SHOP_COST_MULT,
	RAW_AMMO_INC,
	AMMO_INC_MULT,
	HEALTH_REGEN,
	FLAT_ENEMY_HEALTH_REDUCTION,
	ENEMY_HEALTH_MULT,
	ITEM_LEND_THRESHOLD,
	FIRE_SPEED_REDUCTION_MULT,
	GUN_ENEMY_DAMAGE_MULT,
	RAW_GUN_ENEMY_DAMAGE_REDUCTION,
	GUN_ENEMY_TARGETTING_RANGE_MULT,
	PLAYER_DAMAGE_REDUCTION,
	ENEMY_DAMAGE_REDUCTION,
	GUN_TARGETTING_SPEED,
	POWERUP_PICKUP_RANGE,
	CURRENCY_PICKUP_RANGE,
	DROP_VALUE_MULTIPLIER
}

enum Operation {
	ADD,
	MULTIPLY,
	REPLACE,
	EXPONENTIAL,
}

var _stats: Dictionary[Stats, StatDefinition] = {
	Stats.PLAYER_MAX_HEALTH: StatDefinition.new(100),
	Stats.PLAYER_HEALTH: StatDefinition.new(100),
	Stats.PLAYER_SPEED: StatDefinition.new(250),
	Stats.PLAYER_DAMAGE_MULT: StatDefinition.new(1),
	Stats.HEALING_MULT: StatDefinition.new(1),
	Stats.RAW_DAMAGE_MOD: StatDefinition.new(0),
	Stats.RELOAD_SPEED_REDUCTION_MULT: StatDefinition.new(1),
	Stats.TARGETTING_RANGE_MULT: StatDefinition.new(1),
	Stats.GUN_ENEMY_TARGETTING_RANGE_MULT: StatDefinition.new(1),
	Stats.SHOP_COST_MULT: StatDefinition.new(1),
	Stats.RAW_AMMO_INC: StatDefinition.new(0),
	Stats.AMMO_INC_MULT: StatDefinition.new(1),
	Stats.HEALTH_REGEN: StatDefinition.new(0),
	Stats.FLAT_ENEMY_HEALTH_REDUCTION: StatDefinition.new(0),
	Stats.ENEMY_HEALTH_MULT: StatDefinition.new(1),
	Stats.FIRE_SPEED_REDUCTION_MULT: StatDefinition.new(1),
	Stats.RAW_GUN_ENEMY_DAMAGE_REDUCTION: StatDefinition.new(0),
	Stats.GUN_ENEMY_DAMAGE_MULT: StatDefinition.new(1), # todo: like gun_targetting_speed but with a % symbol
	Stats.ITEM_LEND_THRESHOLD: StatDefinition.new(0,-1000,0),
	Stats.PLAYER_DAMAGE_REDUCTION: StatDefinition.new(0, 0, 0.5),
	Stats.ENEMY_DAMAGE_REDUCTION: StatDefinition.new(0, 0, 0.5),
	Stats.GUN_TARGETTING_SPEED: StatDefinition.new(0.2, 0, 1), # lower -> slower, todo: make it appear higher in tooltip (multiply the change with 100) 
	Stats.POWERUP_PICKUP_RANGE: StatDefinition.new(42.86, 0.01),
	Stats.CURRENCY_PICKUP_RANGE: StatDefinition.new(9.64, 0.01),
	Stats.DROP_VALUE_MULTIPLIER: StatDefinition.new(1, 0.1),
}

func get_stat(stat_key: Stats) -> float:
	return _stats[stat_key].current_value if _stats.has(stat_key) else 0.0

func modify_stat(stat_key: Stats, operation: Operation, value: float) -> void:
	if not _stats.has(stat_key):
		return
	
	#FIXME: Not possible, idk why it assigns a random stat definition for item_lend_threshold.
	var stat : StatDefinition = _stats[stat_key]
	var _old_value : float = stat.current_value
	match operation:
		Operation.ADD:
			stat.current_value = clamp(stat.current_value + value, 
									 stat.min_value, 
									 stat.max_value)
		Operation.MULTIPLY:
			stat.current_value = clamp(stat.current_value * value,
									 stat.min_value,
									 stat.max_value)
		Operation.REPLACE:
			stat.current_value = clamp(value,
									 stat.min_value,
									 stat.max_value)
		Operation.EXPONENTIAL:
			stat.current_value = clamp(pow(stat.current_value, value),
									 stat.min_value,
									 stat.max_value)
	
	stat_changed.emit(stat_key, stat.current_value)

#func apply_stat_modifier(stat: StatModifier) -> void:
	#if stat.key == Stats.PLAYER_HEALTH:
		#
	#elif stat.key in game_stats.keys():
		#match stat.operation:
			#Operation.REPLACE:
				#game_stats[stat.key] = stat.value
			#Operation.ADD:
				#game_stats[stat.key] += stat.value
			#Operation.MULTIPLY:
				#game_stats[stat.key] *= stat.value
			#Operation.EXPONENTIAL:
				#game_stats[stat.key] = pow(game_stats[stat.key], stat.value)

func save_stats() -> Dictionary:
	var save_data := {}
	for stat_key in _stats:
		save_data[stat_key] = {
			"base_value": _stats[stat_key].base_value,
			"current_value": _stats[stat_key].current_value,
			"min_value": _stats[stat_key].min_value,
			"max_value": _stats[stat_key].max_value
		}
	return save_data


func load_stats(save_data: Dictionary) -> void:
	for stat_key:Stats in save_data:
		if _stats.has(stat_key):
			var stat_data : StatDefinition = save_data[stat_key]
			_stats[stat_key] = StatDefinition.new(
				stat_data.base_value,
				stat_data.min_value,
				stat_data.max_value
			)
			_stats[stat_key].current_value = stat_data.current_value
