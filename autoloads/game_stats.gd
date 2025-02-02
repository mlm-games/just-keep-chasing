extends Node

# Define your stats as a custom resource
class StatDefinition extends Resource:
	var base_value: float
	var current_value: float
	var min_value: float
	var max_value: float
	
	func _init(base: float, min_val: float = 0, max_val: float = INF):
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
	FIRE_SPEED_REDUCTION_MULT,
	GUN_ENEMY_DAMAGE_MULT,
	RAW_GUN_ENEMY_DAMAGE_REDUCTION,
	GUN_ENEMY_TARGETTING_RANGE_MULT,
	PLAYER_DAMAGE_REDUCTION,
	ENEMY_DAMAGE_REDUCTION,
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
	Stats.SHOP_COST_MULT: StatDefinition.new(1),
	Stats.RAW_AMMO_INC: StatDefinition.new(0),
	Stats.AMMO_INC_MULT: StatDefinition.new(1),
	Stats.HEALTH_REGEN: StatDefinition.new(0),
	Stats.FLAT_ENEMY_HEALTH_REDUCTION: StatDefinition.new(0),
	Stats.ENEMY_HEALTH_MULT: StatDefinition.new(1),
	Stats.FIRE_SPEED_REDUCTION_MULT: StatDefinition.new(1),
	Stats.RAW_GUN_ENEMY_DAMAGE_REDUCTION: StatDefinition.new(0),
	Stats.GUN_ENEMY_DAMAGE_MULT: StatDefinition.new(1),
	Stats.PLAYER_DAMAGE_REDUCTION: StatDefinition.new(0, 0, 0.5),
	Stats.ENEMY_DAMAGE_REDUCTION: StatDefinition.new(0, 0, 0.5),
}

signal stat_changed(stat_name: String, old_value: float, new_value: float)

func get_stat(stat_name: Stats) -> float:
	return _stats[stat_name].current_value if _stats.has(stat_name) else 0.0

func modify_stat(stat_name: Stats, operation: Operation, value: float) -> void:
	if not _stats.has(stat_name):
		return
	
	var stat = _stats[stat_name]
	var old_value = stat.current_value
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
	
	if stat_name == Stats.PLAYER_HEALTH:
		get_tree().get_nodes_in_group("Player")[0].health_component.heal_or_damage(value)
	elif stat_name == Stats.PLAYER_MAX_HEALTH:
		get_tree().get_first_node_in_group("Player").update_max_health(stat.current_value)
	emit_signal("stat_changed", stat_name, old_value, stat.current_value)

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
		#if stat.key == Stats.PLAYER_MAX_HEALTH:
			##Update max_health in player's health component
			#get_tree().get_nodes_in_group("Player")[0].update_max_health(game_stats[Stats.PLAYER_MAX_HEALTH])


# enemy_id: no of kills
var enemy_kill_count: Dictionary[String, int] = { 
	"small_slime": 0,
	"basic_slime": 0,
	"evolved_slime": 0,
}

func save_stats() -> Dictionary:
	var save_data := {}
	for stat_name in _stats:
		save_data[stat_name] = {
			"base_value": _stats[stat_name].base_value,
			"current_value": _stats[stat_name].current_value,
			"min_value": _stats[stat_name].min_value,
			"max_value": _stats[stat_name].max_value
		}
	return save_data


func load_stats(save_data: Dictionary) -> void:
	for stat_name in save_data:
		if _stats.has(stat_name):
			var stat_data = save_data[stat_name]
			_stats[stat_name] = StatDefinition.new(
				stat_data.base_value,
				stat_data.min_value,
				stat_data.max_value
			)
			_stats[stat_name].current_value = stat_data.current_value
