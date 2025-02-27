class_name GameSettingsSave extends Resource




#  { "category": { "setting_name": value } }
@export var settings: Dictionary = {}

# Try to fix settings not being applied properly?
func _init() -> void:
	if settings.is_empty():
		settings = DEFAULT_SETTINGS
	

func get_setting(category: String, setting_name: String, default):
	if settings.has(category) and settings[category].has(setting_name):
		return settings[category][setting_name]
	if default: return default 
	return DEFAULT_SETTINGS[category][setting_name]

#idk why this but most ppl use it
func set_setting(category: String, setting_name: String, value) -> void:
	if not settings.has(category):
		settings[category] = {}
	
	settings[category][setting_name] = value

#HACK: For temporary settings only,just add the settings in the 'DEFAULT_SETTINGS' constant.
func register_setting(category: String, setting_name: String, default_value) -> void:
	if not settings.has(category):
		settings[category] = {}
	
	if not settings[category].has(setting_name):
		settings[category][setting_name] = default_value

func apply_settings(reload_and_apply: bool = false) -> void:
	if reload_and_apply:
		SettingsData.load_settings()
		settings = SettingsData.loaded_data.settings
	if settings.has("video"):
		var video = settings["video"]
		if video.has("fullscreen"):
			if video["fullscreen"]:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
			else:
				DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		
		if video.has("borderless"):
			DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, video["borderless"])
		
		if video.has("resolution") and not video.get("fullscreen", false):
			var resolution = video["resolution"]
			DisplayServer.window_set_size(resolution)
			var screen_size = DisplayServer.screen_get_size()
			DisplayServer.window_set_position(screen_size * 0.5 - resolution * 0.5)
	
	if settings.has("audio"):
		var audio = settings["audio"]
		for bus_name in audio:
			var bus_index = AudioServer.get_bus_index(bus_name)
			if bus_index >= 0:
				AudioServer.set_bus_volume_db(bus_index, linear_to_db(audio[bus_name]))
	
	#Add later stuff here
	if settings.has("gameplay"):
		var gameplay = settings["gameplay"]
		if gameplay.has("max_fps"):
			Engine.max_fps = gameplay["max_fps"]
	
	if settings.has("accessibility"):
		var accessibility = settings["accessibility"]
		if accessibility.has("current_locale"):
			TranslationServer.set_locale(accessibility["current_locale"])


const DEFAULT_SETTINGS = {
	"accessibility": {
			"current_locale": "en",
			"small_text_font_size": 20,
			"big_text_font_size": 64,
		},
	"gameplay": {
			"max_fps": 60,
			"pause_on_lost_focus": true,
			"show_damage_numbers": true,
			"hide_touch_buttons": false,
			"lazy_mode": false,
		},
	"video": {
			"borderless": false,
			"fullscreen": true,
			"resolution": Vector2i(1080, 720),
		},
	"audio": {
			"Master": 100,
			"Music": 100,
			"SFX": 100,
		}
}


const LOCALES = {
	"en": "English",
	"fr": "French / Français",
	"es": "Spanish / Español",
	"de": "German / Deutsch",
	"it": "Italian / Italiano",
	"br": "Portuguese / Português (BR)",
	"pt": "Portuguese / Português (PT)",
	"ru": "Russian / Русский",
	"el": "Greek / Ελληνικά",
	"tr": "Turkish / Türkçe",
	"da": "Danish / Dansk",
	"nb": "Norwegian (NB) / Norsk Bokmål",
	"sv": "Swedish / Svenska",
	"nl": "Dutch / Nederlands",
	"pl": "Polish / Polski",
	"fi": "Finnish / Suomi",
	"ja": "Japanese / 日本語",
	"zh": "Simplified Chinese / 简体中文",
	"lzh": "Traditional Chinese / 繁体中文",
	"ko": "Korean / 한국어",
	"cs": "Czech / Čeština",
	"hu": "Hungarian / Magyar",
	"ro": "Romanian / Română",
	"th": "Thai / ภาษาไทย",
	"bg": "Bulgarian / Български",
	"he": "Hebrew / עברית",
	"ar": "Arabic / العربية",
	"bs": "Bosnian"
}

const RESOLUTIONS_ARRAY : Array[Vector2i] = [
	Vector2i(640, 360),
	Vector2i(960, 540),
	Vector2i(1024, 576),
	Vector2i(1280, 720),
	Vector2i(1600, 900),
	Vector2i(1920, 1080),
	Vector2i(2048, 1152),
	Vector2i(2560, 1440),
	Vector2i(3200, 1800),
	Vector2i(3840, 2160),
]
