extends Node

const SAVE_FILE_PATH = "user://count_stats.save"

# ("total", "powerups", etc...) are "categories"
var _all_stats: Dictionary = {
	"total": {
		"damage_dealt": 0.0,
		"damage_taken": 0.0,
		"enemies_killed": 0,
		"powerups_used": 0,
		"games_won": 0,
		"games_played": 0,
		"health_healed": 0.0,
		"mito_energy_collected": 0,
		"longest_run_time": 0.0,
		"bullets_fired": 0
	},
	"powerups": {},
	"enemies": {},
	"guns": {},
	"augments": {},
	"unlocked_guns": {},
	"unlocked_enemies": {},
	"unlocked_augments": {},
}

var _is_dirty := false

signal stat_updated(stat_key: StringName, new_value: Variant)


func _ready() -> void:
	_initialize_dynamic_stats()
	load_stats()


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		request_save()
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		request_save()


# ensures even if a save file is old, all current items have a stat entry.
func _initialize_dynamic_stats() -> void:
	for enemy_type: EnemyData in CollectionManager.all_enemies.values():
		var key = get_stat_key(enemy_type)
		_all_stats.enemies[key] = _all_stats.enemies.get(key, 0)
		_all_stats.unlocked_enemies[key] = _all_stats.unlocked_enemies.get(key, enemy_type.unlocked)
	
	for gun_type: GunData in CollectionManager.all_guns.values():
		var key = get_stat_key(gun_type)
		_all_stats.guns[key] = _all_stats.guns.get(key, 0)
		_all_stats.unlocked_guns[key] = _all_stats.unlocked_guns.get(key, gun_type.unlocked)
	
	for augment_type: AugmentsData in CollectionManager.all_augments.values():
		var key = get_stat_key(augment_type)
		_all_stats.augments[key] = _all_stats.augments.get(key, 0)
		_all_stats.unlocked_augments[key] = _all_stats.unlocked_augments.get(key, augment_type.unlocked)
	
	for powerup_type: PowerupData in CollectionManager.all_powerups.values():
		var key = get_stat_key(powerup_type)
		_all_stats.powerups[key] = _all_stats.powerups.get(key, 0)


func request_save() -> void:
	if _is_dirty:
		_save_to_disk()
		_is_dirty = false


## Increments a stat by a given amount.
## Finds the stat automatically across all categories.
func increment_stat(stat_key: StringName, amount: Variant = 1) -> void:
	for category in _all_stats.values():
		if category is Dictionary and category.has(stat_key):
			category[stat_key] += amount
			stat_updated.emit(stat_key, category[stat_key])
			_is_dirty = true
			return
	
	push_warning("Attempted to increment a non-existent stat key: %s" % stat_key)


func set_stat(stat_key: StringName, value: Variant) -> void:
	for category in _all_stats.values():
		if category is Dictionary and category.has(stat_key):
			if category[stat_key] != value:
				category[stat_key] = value
				stat_updated.emit(stat_key, value)
				_is_dirty = true
			return
	
	push_warning("Attempted to set a non-existent stat key: %s" % stat_key)


## Gets the current value of any stat.
func get_stat(stat_key: StringName) -> Variant:
	for category in _all_stats.values():
		if category is Dictionary and category.has(stat_key):
			return category[stat_key]
	
	return null


func update_longest_run_time(current_time: float) -> void:
	var longest_time = get_stat("longest_run_time")
	if longest_time == null:
		longest_time = 0.0
	
	if current_time > longest_time:
		set_stat("longest_run_time", current_time)


func _save_to_disk() -> void:
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Failed to open save file for writing: %s. Error: %s" % [SAVE_FILE_PATH, error_string(FileAccess.get_open_error())])
		return
	
	file.store_var(_all_stats)
	file.close()
	print("Game stats saved.")


func load_stats() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("No save file found. Using default stats.")
		return

	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not file:
		push_error("Failed to open save file for reading: %s. Error: %s" % [SAVE_FILE_PATH, error_string(FileAccess.get_open_error())])
		return
	
	if file.get_length() == 0:
		push_warning("Save file is empty, cannot load stats.")
		file.close()
		return

	var loaded_data = file.get_var()
	file.close()
	
	if not loaded_data is Dictionary:
		push_error("Save file is corrupted or in an unknown format.")
		return
	
	# Merge loaded data
	for category_key in _all_stats:
		if loaded_data.has(category_key):
			var current_category_dict: Dictionary = _all_stats[category_key]
			var loaded_category_dict = loaded_data[category_key]
			
			if loaded_category_dict is Dictionary:
				for stat_key in current_category_dict:
					if loaded_category_dict.has(stat_key):
						current_category_dict[stat_key] = loaded_category_dict[stat_key]

	print("Game stats loaded successfully.")
	_apply_unlocks_to_collections()


func _apply_unlocks_to_collections() -> void:
	for gun_name in _all_stats.unlocked_guns:
		var is_unlocked = _all_stats.unlocked_guns[gun_name]
		var gun_data = CollectionManager.all_guns.get(gun_name)
		if gun_data:
			gun_data.unlocked = is_unlocked
			if is_unlocked:
				GameState.unlocked_guns[gun_name] = gun_data
	
	for enemy_name in _all_stats.unlocked_enemies:
		var is_unlocked = _all_stats.unlocked_enemies[enemy_name]
		var enemy_data = CollectionManager.all_enemies.get(enemy_name)
		if enemy_data:
			enemy_data.unlocked = is_unlocked
			if is_unlocked:
				GameState.unlocked_enemies[enemy_name] = enemy_data
	
	for augment_name in _all_stats.unlocked_augments:
		var is_unlocked = _all_stats.unlocked_augments[augment_name]
		var augment_data = CollectionManager.all_augments.get(augment_name)
		if augment_data:
			augment_data.unlocked = is_unlocked
			if is_unlocked:
				GameState.unlocked_augments[augment_name] = augment_data


static func get_stat_key(data: Resource) -> StringName:
	return CollectionManager.get_resource_name(data)
