extends Node
#class_name AchievementManager

class Achievement:
	var name: String
	var description: String
	var is_secret: bool
	var count_goal: int
	var current_progress: float
	var icon_path: String
	var unlocked: bool
	var active: bool
	var reward: String
	
	func _init(p_name := "", p_description := "", p_is_secret := false, 
			   p_count_goal := 0, p_icon_path := "", p_active := true, p_reward := "") -> void:
		name = p_name
		description = p_description
		is_secret = p_is_secret
		count_goal = p_count_goal
		current_progress = 0.0
		icon_path = p_icon_path
		unlocked = false
		active = p_active
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
			"reward": reward
		}

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
		achievement.reward = dict.get("reward", "")
		return achievement

signal achievement_unlocked(achievement_id: String, achievement: Achievement)
signal achievement_updated(achievement_id: String, achievement: Achievement)
signal achievement_reset(achievement_id: String, achievement: Achievement)
signal all_achievements_unlocked

const SETTINGS_BASE = "basic_achievements/achievements"

var achievements: Dictionary = {}
var unlocked_achievements: Dictionary = {}

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
		unlocked_achievements[id] = achievement
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
	var local_source = ProjectSettings.get_setting(SETTINGS_BASE + "/local_source")
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
		var file := FileAccess.open_encrypted_with_pass(
			save_path,
			FileAccess.READ,
			ProjectSettings.get_setting(SETTINGS_BASE + "/password")
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
	
	var file := FileAccess.open_encrypted_with_pass(
		_get_save_path(),
		FileAccess.WRITE,
		ProjectSettings.get_setting(SETTINGS_BASE + "/password")
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
