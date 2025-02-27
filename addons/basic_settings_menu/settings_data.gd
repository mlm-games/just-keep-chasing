extends Node

const SettingsScene: String = "res://addons/basic_settings_menu/settings.tscn"

@onready var loaded_data : GameSettingsSave

func _ready():
	load_settings(true)

func save_settings() -> void:
	if loaded_data == null:
		loaded_data = GameSettingsSave.new()
	
	var error := ResourceSaver.save(loaded_data, SETTINGS_SAVE_RES_PATH)
	
	if error != OK:
		push_error("Failed to save settings to: %s, error: %d" % [SETTINGS_SAVE_RES_PATH, error])
	else:
		print("Settings successfully saved to: %s" % SETTINGS_SAVE_RES_PATH)

func load_settings(with_ui_update : bool = false, safe: bool = true) -> bool:
	if !FileAccess.file_exists(SETTINGS_SAVE_RES_PATH):
		print("Settings save file not found.")
		# Initialize with defaults
		loaded_data = GameSettingsSave.new()
		save_settings()
		return false
	
	print("Settings file was found.")
	
	var loaded_resource = load(SETTINGS_SAVE_RES_PATH)
	
	if loaded_resource == null:
		push_error("Failed to load settings from: %s" % SETTINGS_SAVE_RES_PATH)
		# Initialize with defaults
		loaded_data = GameSettingsSave.new()
		return false
		
	loaded_data = loaded_resource
	
	if with_ui_update:
		loaded_data.apply_settings()
	
	return true

func go_back_to_previous_scene_or_main_scene(main_scene: bool = true):
	if main_scene:
		get_tree().change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))

func exit_settings(settings_scene: SettingsUI):
	settings_scene.queue_free()










const SETTINGS_SAVE_RES_PATH: String = "user://settings.tres"
