class_name GameSettingsSave extends Resource

var input_profiles: Dictionary

var accessibility: Dictionary = {
	"current_locale": "en",
	"small_text_font_size": 20,
	"big_text_font_size": 64,
}

var gameplay_options: Dictionary = {
	"max_fps": 60,
	"pause_on_lost_focus": true,
	"show_damage_numbers": true,
	"use_auto_aim": true,
	"hide_touch_buttons": true
}
var video: Dictionary = {
	"borderless": false,
	"fullscreen": true,
	"resolution": Vector2i(1080, 720),
}
var audio: Dictionary = {
	"Master": 100,
	"Music": 100,
	"SFX": 100,
}
