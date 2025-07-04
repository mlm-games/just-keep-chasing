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

#tracks if data has changed, preventing unnecessary disk writes.
var _is_dirty := false

signal stat_updated(stat_key: StringName, new_value: Variant)


func _ready() -> void:
	_initialize_dynamic_stats()
	load_stats()


func _notification(what: int) -> void:
	# Automatically save any changed data when the game window is closed.
	#if what == NOTIFICATION_WM_CLOSE_REQUEST or what == NOTIFICATION_WM_GO_BACK_REQUEST:
		#request_save()
	if what == NOTIFICATION_PREDELETE:
		request_save()



# ensures even if a save file is old, all current items have a stat entry.
func _initialize_dynamic_stats() -> void:
	for enemy_type: EnemyData in CollectionManager.all_enemies.values():
		var key = get_stat_key(enemy_type)
		_all_stats.enemies[key] = 0
		_all_stats.unlocked_enemies[key] = enemy_type.unlocked
	
	for gun_type: GunData in CollectionManager.all_guns.values():
		var key = get_stat_key(gun_type)
		_all_stats.guns[key] = 0
		_all_stats.unlocked_guns[key] = gun_type.unlocked
	
	for augment_type: AugmentsData in CollectionManager.all_augments.values():
		var key = get_stat_key(augment_type)
		_all_stats.augments[key] = 0
		_all_stats.unlocked_augments[key] = augment_type.unlocked
	
	for powerup_type: PowerupData in CollectionManager.all_powerups.values():
		var key = get_stat_key(powerup_type)
		_all_stats.powerups[key] = 0


## Call this from other scripts to trigger a save, e.g., when returning to the main menu.
func request_save() -> void:
	if _is_dirty:
		_save_to_disk()
		_is_dirty = false # Reset the flag after saving.


## Increments a stat by a given amount.
## Finds the stat automatically across all categories.
func increment_stat(stat_key: StringName, amount: Variant = 1) -> void:
	for category in _all_stats.values():
		if category.has(stat_key):
			category[stat_key] += amount
			stat_updated.emit(stat_key, category[stat_key])
			_is_dirty = true # Mark that we have unsaved changes.
			return
	
	push_error("Attempted to increment a non-existent stat key: %s" % stat_key)


## Sets a stat to a specific value. Useful for things like "longest_run_time".
func set_stat(stat_key: StringName, value: Variant) -> void:
	for category in _all_stats.values():
		if category.has(stat_key):
			# Only update and mark as dirty if the value actually changes.
			if category[stat_key] != value:
				category[stat_key] = value
				stat_updated.emit(stat_key, value)
				_is_dirty = true
			return
			
	push_error("Attempted to set a non-existent stat key: %s" % stat_key)


## Gets the current value of any stat.
func get_stat(stat_key: StringName) -> Variant:
	for category in _all_stats.values():
		if category.has(stat_key):
			return category[stat_key]
			
	push_warning("Attempted to get a non-existent stat key: %s" % stat_key)
	return null # Or 0


func update_longest_run_time(current_time: float) -> void:
	var longest_time = get_stat("longest_run_time")
	if current_time > longest_time:
		set_stat("longest_run_time", current_time)
		# No need to save here, it will be handled on exit or via request_save().



## The actual file writing operation. Kept private.
func _save_to_disk() -> void:
	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if not file:
		push_error("Failed to open save file for writing: %s. Error: %s" % [SAVE_FILE_PATH, error_string(FileAccess.get_open_error())])
		return
		
	file.store_var(_all_stats)
	print("Game stats saved.")


## Loads stats from disk and safely merges them with the current data structure.
func load_stats() -> void:
	if not FileAccess.file_exists(SAVE_FILE_PATH):
		print("No save file found. Using default stats.")
		return

	var file := FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
	if not file:
		push_error("Failed to open save file for reading: %s. Error: %s" % [SAVE_FILE_PATH, error_string(FileAccess.get_open_error())])
		return
	
	# Check for empty file to prevent errors
	if file.get_length() == 0:
		push_warning("Save file is empty, cannot load stats.")
		return

	var loaded_data: Dictionary = file.get_var()
	if not loaded_data is Dictionary:
		push_error("Save file is corrupted or in an unknown format.")
		return
	
	# **This is the key:** We MERGE the loaded data.
	# This makes the process robust against adding/removing stat keys between game versions.
	for category_key in _all_stats: # Iterate through our *current* categories ("total", "enemies", etc.)
		if loaded_data.has(category_key):
			var current_category_dict: Dictionary = _all_stats[category_key]
			var loaded_category_dict: Dictionary = loaded_data[category_key]
			
			for stat_key in current_category_dict: # Iterate through our *current* stat keys
				if loaded_category_dict.has(stat_key):
					# Overwrite the default value with the saved value.
					current_category_dict[stat_key] = loaded_category_dict[stat_key]

	print("Game stats loaded successfully. Applying unlocks to collection_manager and gamestate")
	_apply_unlocks_to_collections()

func _apply_unlocks_to_collections():
	for gun_data in CollectionManager.all_guns.values():
		gun_data.unlocked = _all_stats.unlocked_guns.has(get_stat_key(gun_data))
		if gun_data.unlocked:
			GameState.unlocked_guns.get_or_add(get_stat_key(gun_data), gun_data)
	
	for enemy_data in CollectionManager.all_enemies.values():
		enemy_data.unlocked = _all_stats.unlocked_enemies.has(get_stat_key(enemy_data))
		if enemy_data.unlocked:
			GameState.unlocked_enemies.get_or_add(get_stat_key(enemy_data), enemy_data)
	
	for augment_data in CollectionManager.all_augments.values():
		augment_data.unlocked = _all_stats.unlocked_augments.has(get_stat_key(augment_data))
		if augment_data.unlocked:
			GameState.unlocked_augments.get_or_add(get_stat_key(augment_data), augment_data)


static func get_stat_key(data: Resource) -> StringName:
	return CollectionManager.get_resource_name(data)
