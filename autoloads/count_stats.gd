extends Node

var total_count_stats : Dictionary[StringName, int] = {
	"damage_dealt": 0,
	"enemies_killed": 0,
	"powerups_used": 0,
	"games_won": 0,
	"games_played": 0,
	"slow_time_used": 0,
	"screen_blast_used": 0,
	"heal_used": 0,
	"invincible_used": 0
}

var powerup_use_stats: Dictionary = GameState.powerups.duplicate(true)

var enemies_killed_stats : Dictionary[StringName, int] = {}

var bullets_fired_by_type_stats : Dictionary[StringName, int] = {}

var augment_collection_stats : Dictionary[StringName, int] = {}

@warning_ignore("untyped_declaration")
func increment_stat(stat_name, amount: int = 1, stat_dict: Dictionary = total_count_stats) -> void:
	if stat_dict.has(stat_name):
		stat_dict[stat_name] += amount
		stat_updated.emit(stat_name, stat_dict[stat_name])

signal stat_updated(stat_name: String, new_value: int)

func get_stat(stat_name: String) -> int:
	return total_count_stats.get(stat_name, 0)
