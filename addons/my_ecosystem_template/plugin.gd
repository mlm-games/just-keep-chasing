@tool
extends EditorPlugin

#const SETTINGS_PATH = "ecosystem/config"
#const DEFAULT_CONFIG_PATH = "res://addons/my-ecosystem-template/default_config.tres"
#
#func _enter_tree() -> void:
	#_setup_project_settings()
	#
	#if ProjectSettings.get_setting("ecosystem/enable_autoload", true):
		#add_autoload_singleton("Ecosystem", "res://addons/my-ecosystem-template/ecosystem_manager.gd")
#
#func _exit_tree() -> void:
	#remove_autoload_singleton("Ecosystem")
#
#func _setup_project_settings() -> void:
	#var settings = {
		#"ecosystem/enable_autoload": true,
		#"ecosystem/config": DEFAULT_CONFIG_PATH,
		#"ecosystem/audio/enable_ui_sounds": true,
		#"ecosystem/audio/ui_bus": "UI",
		#"ecosystem/transitions/default_duration": 0.3,
		#"ecosystem/transitions/default_type": "fade"
	#}
	#
	#for key in settings:
		#if not ProjectSettings.has_setting(key):
			#ProjectSettings.set_setting(key, settings[key])
	#
	#ProjectSettings.save()
