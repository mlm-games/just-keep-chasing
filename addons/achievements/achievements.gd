#class_name AchievementManager
extends Node

signal achievement_unlocked(achievement: Achievement)
signal achievement_updated(achievement: Achievement)
signal achievement_reset(achievement: Achievement)
signal all_achievements_unlocked

const SETTINGS_BASE = "basic_achievements/achievements"

var achievements: Dictionary[String, Achievement] = {}
var unlocked_achievements: Array[String] = []


func _ready() -> void:
	_initialize_achievements()


func get_achievement(id: String) -> Achievement:
	return achievements.get(id)


func get_all_achievements() -> Array[Achievement]:
	return achievements.values()


func update_achievement(id: String, progress_increase: float) -> void:
	var achievement := get_achievement(id)
	if not achievement:
		push_warning("Achievement System: Tried to update non-existent achievement with id: " + id)
		return
	
	if achievement.unlocked:
		return

	achievement.current_progress = min(achievement.current_progress + progress_increase, achievement.count_goal)
	
	if achievement.current_progress >= achievement.count_goal:
		unlock_achievement(id)
	else:
		achievement_updated.emit(achievement)
		_save_achievements()


func unlock_achievement(id: String) -> void:
	var achievement := get_achievement(id)
	if not achievement:
		push_warning("Achievement System: Tried to unlock non-existent achievement with id: " + id)
		return

	if achievement.unlocked:
		return
		
	achievement.unlocked = true
	achievement.current_progress = achievement.count_goal
	unlocked_achievements.append(id)
	
	achievement_unlocked.emit(achievement)
	_save_achievements()
	_check_all_achievements()


func reset_all_achievements() -> void:
	for id in achievements:
		reset_achievement(id)


func reset_achievement(id: String) -> void:
	var achievement := get_achievement(id)
	if achievement:
		achievement.unlocked = false
		achievement.current_progress = 0.0
		if unlocked_achievements.has(id):
			unlocked_achievements.erase(id)
		
		achievement_reset.emit(achievement)
		_save_achievements()


func _initialize_achievements() -> void:
	_load_achievements()
	_sync_saved_achievements()


func _load_achievements() -> void:
	var achievements_dir = ProjectSettings.get_setting(SETTINGS_BASE + "/local_source")
	var dir = DirAccess.open(achievements_dir)
	
	if not dir:
		push_error("Achievement directory not found: " + achievements_dir + ". Please check your Project Settings.")
		return
	
	dir.list_dir_begin()
	var file_name = dir.get_next()
	while file_name != "":
		if not dir.current_is_dir() and file_name.ends_with(".tres"):
			var achievement: Achievement = load(achievements_dir.path_join(file_name))
			if achievement and achievement.id == "":
				achievements[achievement.title.to_snake_case()] = achievement
			else:
				push_error("Click here")
		file_name = dir.get_next()


func _sync_saved_achievements() -> void:
	var save_path := _get_save_path()
	if not FileAccess.file_exists(save_path):
		return

	var file_content = FileAccess.get_file_as_string(save_path)
	var parsed_data = JSON.parse_string(file_content)

	if not parsed_data is Dictionary:
		push_warning("Failed to parse achievements save file or file is empty.")
		return

	for id in parsed_data:
		if not achievements.has(id):
			continue # Skip saved data for achievements that no longer exist

		var saved_state: Dictionary = parsed_data[id]
		var achievement_instance: Achievement = achievements[id]
		
		achievement_instance.current_progress = saved_state.get("progress", 0.0)
		achievement_instance.unlocked = saved_state.get("unlocked", false)

		if achievement_instance.unlocked and not unlocked_achievements.has(id):
			unlocked_achievements.append(id)


func _save_achievements() -> void:
	var save_data := {}
	for id in achievements:
		var achievement = achievements[id]
		# Only save the state, not the definition
		save_data[id] = {
			"progress": achievement.current_progress,
			"unlocked": achievement.unlocked
		}
	
	var file = FileAccess.open_encrypted_with_pass(
		_get_save_path(),
		FileAccess.WRITE,
		ProjectSettings.get_setting(SETTINGS_BASE + "/password")
	)
	var error = FileAccess.get_open_error()
	if error == OK:
		file.store_string(JSON.stringify(save_data))
		file.close()

func _get_save_path() -> String:
	var dir = ProjectSettings.get_setting(SETTINGS_BASE + "/save_directory")
	DirAccess.make_dir_absolute(dir)
	return dir


func _check_all_achievements() -> void:
	if unlocked_achievements.size() == achievements.size():
		all_achievements_unlocked.emit()
