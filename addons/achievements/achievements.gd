#class_name AchievementManager
extends Node


signal achievement_unlocked(achievement_id: String, achievement: Achievement)
signal achievement_updated(achievement_id: String, achievement: Achievement)
signal achievement_reset(achievement_id: String, achievement: Achievement)
signal all_achievements_unlocked

const SETTINGS_BASE = "basic_achievements/achievements"

var achievements: Dictionary = {}
var unlocked_achievements: Array[String] = []

func _ready() -> void:
	_initialize_achievements()

func _initialize_achievements() -> void:
	_load_achievements()
	_sync_saved_achievements()

func get_achievement(id: String) -> Achievement:
	return achievements.get(id)

func update_achievement(id: String, progress: float) -> void:
	var achievement := get_achievement(id)
	if achievement and not achievement.unlocked:
		achievement.current_progress = minf(progress, achievement.count_goal)
		if achievement.current_progress >= achievement.count_goal:
			unlock_achievement(id)
		achievement_updated.emit(id, achievement)
		_save_achievements()

func unlock_achievement(id: String) -> void:
	var achievement := get_achievement(id)
	if achievement and not achievement.unlocked:
		achievement.unlocked = true
		achievement.current_progress = achievement.count_goal
		unlocked_achievements.append(id)
		achievement_unlocked.emit(id, achievement)
		_save_achievements()
		_check_all_achievements()

func reset_achievement(id: String) -> void:
	var achievement := get_achievement(id)
	if achievement:
		achievement.unlocked = false
		achievement.current_progress = 0.0
		unlocked_achievements.erase(id)
		achievement_reset.emit(id, achievement)
		_save_achievements()

func _load_achievements() -> void:
	var local_source = "res://autoloads/achievements_data.gd" #ProjectSettings.get_setting(SETTINGS_BASE + "/local_source")
	if FileAccess.file_exists(local_source):
		var content = load(local_source).achievements
		if content:
			for id in content:
				achievements[id] = Achievement.from_dict(content[id])
	else:
		push_error("File doesn't exist.")

func _sync_saved_achievements() -> void:
	var save_path := _get_save_path()
	if FileAccess.file_exists(save_path):
		var file := FileAccess.open(
			save_path,
			FileAccess.READ,
			#ProjectSettings.get_setting(SETTINGS_BASE + "/password")
		)
		if file:
			var content = JSON.parse_string(file.get_as_text())
			if content:
				for id in content:
					if achievements.has(id):
						var saved_achievement := Achievement.from_dict(content[id])
						achievements[id].unlocked = saved_achievement.unlocked
						achievements[id].current_progress = saved_achievement.current_progress
						if saved_achievement.unlocked:
							unlocked_achievements[id] = achievements[id]

func _save_achievements() -> void:
	var save_data := {}
	for id in achievements:
		save_data[id] = achievements[id].to_dict()
	
	var file := FileAccess.open(
		_get_save_path(),
		FileAccess.WRITE,
		#ProjectSettings.get_setting(SETTINGS_BASE + "/password")
	)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

func _get_save_path() -> String:
	return ProjectSettings.get_setting(SETTINGS_BASE + "/save_directory").path_join(
		ProjectSettings.get_setting(SETTINGS_BASE + "/save_file_name")
	)

func _check_all_achievements() -> void:
	if unlocked_achievements.size() == achievements.size():
		all_achievements_unlocked.emit()
