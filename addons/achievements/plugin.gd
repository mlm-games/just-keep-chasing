@tool
extends EditorPlugin

#Based on https://github.com/BananaHolograma/Achievements


const SETTINGS_BASE = "basic_achievements" # to_snake_case doesnt get considered as a constant
const DEFAULT_SETTINGS = [
	{
		"name": SETTINGS_BASE + "/achievements/local_source",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_FILE,
		"hint_string": "*.json",
		"value": "res://achievements.json"
	},
	#{
		#"name": SETTINGS_BASE + "/achievements/save_directory",
		#"type": TYPE_STRING,
		#"hint": PROPERTY_HINT_DIR,
		#"value": "user://achievements"
	#},
	{
		"name": SETTINGS_BASE + "/achievements/save_file_name",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_NONE,
		"value": "achievements_save.dat"
	},
	{
		"name": SETTINGS_BASE + "/achievements/password",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_NONE,
		"value": ""
	}
]

func _enter_tree() -> void:
	_setup_settings()
	add_autoload_singleton(SETTINGS_BASE.to_pascal_case(), "res://addons/achievements/achievements.gd")


func _exit_tree() -> void:
	remove_autoload_singleton(SETTINGS_BASE.to_pascal_case())
	_remove_settings();


func _setup_settings() -> void:
	for setting in DEFAULT_SETTINGS:
		if not ProjectSettings.has_setting(setting["name"]):
			
			ProjectSettings.set_setting(setting["name"], setting["value"])
			if setting["name"].ends_with("password"):
				ProjectSettings.set_setting(setting["name"], _generate_random_string(25))
			
			var property_info := {
				"name": setting["name"],
				"type": setting["type"],
				"hint": setting["hint"]
			}
			
			if setting.has("hint_string"):
				property_info["hint_string"] = setting["hint_string"]
				
			ProjectSettings.add_property_info(property_info)
	
	ProjectSettings.save()


func _remove_settings() -> void:
	for setting in DEFAULT_SETTINGS:
		if ProjectSettings.has_setting(setting["name"]):
			ProjectSettings.set_setting(setting["name"], null)
	
	ProjectSettings.save()


func _generate_random_string(length: int, characters: String = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789") -> String:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	
	var result := ""
	if not characters.is_empty() and length > 0:
		for i in range(length):
			result += characters[rng.randi() % characters.length()]
	
	return result
