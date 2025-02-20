extends Node

const SETTINGS_SAVE_RES_PATH: String = "user://settings.tres"
const SettingsScene: String = "res://addons/basic_settings_menu/settings.tscn"

@onready var loaded_data : GameSettingsSave = GameSettingsSave.new()

func _ready():
	load_settings(true)

func save_settings() -> void:
	var new_save : GameSettingsSave = GameSettingsSave.new()
	new_save.accessibility.merge(loaded_data.accessibility.duplicate(true))
	new_save.gameplay_options.merge(loaded_data.gameplay_options.duplicate(true))
	new_save.video.merge(loaded_data.video.duplicate(true))
	new_save.audio.merge(loaded_data.audio.duplicate(true))
	
	#get_or_create_dir(CONFIG_DIR)
	var save_result := ResourceSaver.save(new_save, SETTINGS_SAVE_RES_PATH)
	
	if save_result != OK:
		push_error("Failed to save settings to: %s" % SETTINGS_SAVE_RES_PATH)
	else:
		print("Settings successfully saved to: %s" % SETTINGS_SAVE_RES_PATH)

func load_settings(with_ui_update : bool = false, safe: bool = true) -> bool:
	if !ResourceLoader.exists(SETTINGS_SAVE_RES_PATH):
		print("Settings save file not found.")
		return false
	
	print("Settings file was found.")
	var loaded_data: GameSettingsSave = ResourceLoader.load(SETTINGS_SAVE_RES_PATH, "Resource", ResourceLoader.CACHE_MODE_REUSE)
	
	if loaded_data == null:
		push_error("Failed to load settings from: %s" % SETTINGS_SAVE_RES_PATH)
		return false
	
	#if safe:
		#for i in accessibility.keys():
			#if loaded_data.accessibility[i]: accessibility[i] = loaded_data.accessibility[i]; accessibility.get_or_add(i, accessibility[i])
			#if loaded_data.audio[i]: audio[i] = loaded_data.audio[i]
			#if loaded_data.video[i]: video[i] = loaded_data.video[i]
			#if loaded_data.gameplay_options[i]: gameplay_options[i] = loaded_data.gameplay_options[i]
	#else:
		#accessibility.merge(loaded_data.accessibility.duplicate(true), true)
		#gameplay_options.merge(loaded_data.gameplay_options.duplicate(true), true)
		#video.merge(loaded_data.video.duplicate(true), true)
		#audio.merge(loaded_data.audio.duplicate(true), true)
	
	if with_ui_update == true:
		var settings_instance = load(SettingsScene).instantiate()
		add_child(settings_instance)
		#await settings_instance.sign
		remove_child(settings_instance)
		settings_instance.queue_free()
	
	return true

func go_back_to_previous_scene_or_main_scene(main_scene: bool = true):
	if main_scene:
		get_tree().change_scene_to_file(ProjectSettings.get_setting("application/run/main_scene"))

func exit_settings(settings_scene: SettingsUI):
	settings_scene.queue_free()
