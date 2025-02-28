@tool
extends HBoxContainer

@export var setting_name : StringName: # ="EXAMPLE_SETTING"
	set(name):
		setting_name = tr(name)
		if Engine.is_editor_hint() and ready: label.text = setting_name

@onready var modifiable_part_of_setting : Control = $ModifiablePartOfSetting
@onready var label: Label = $Label

func _ready() -> void:
	label.text = setting_name
	if modifiable_part_of_setting is Range:
		modifiable_part_of_setting.value_changed.connect(_on_modifiable_part_of_setting_value_changed.bind())
	if modifiable_part_of_setting is CheckButton:
		modifiable_part_of_setting.toggled.connect(_on_modifiable_part_of_setting_value_changed.bind())
	if modifiable_part_of_setting is OptionButton:
		modifiable_part_of_setting.item_selected.connect(_on_modifiable_part_of_setting_value_changed.bind())
	set_initial_state()

func set_initial_state():
	var setting_name = name.to_snake_case()
	var category = get_parent().name.to_snake_case()
	if modifiable_part_of_setting is OptionButton: #For option buttons, add here
		if setting_name == "current_locale":
			modifiable_part_of_setting.grab_focus()
			populate_and_set_locale_button_item()
		elif setting_name == "resolution":
			populate_and_set_resolution_button_item()
		else:
			modifiable_part_of_setting.select(modifiable_part_of_setting.get_item_metadata(SettingsData.loaded_data.settings[category][setting_name]))
	elif modifiable_part_of_setting is CheckButton:
		modifiable_part_of_setting.button_pressed = SettingsData.loaded_data.settings[category][setting_name]
	elif modifiable_part_of_setting is Range:
		if "volume" in setting_name or "slider" in setting_name:
			var bus_name = setting_name.replace("_volume", "").replace("_slider", "").capitalize()
			SettingsData.loaded_data.settings[category][bus_name] = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus_name)))
		else:
			modifiable_part_of_setting.value = SettingsData.loaded_data.settings[category][setting_name]

func _on_modifiable_part_of_setting_value_changed(value: float) -> void:
	var setting_name = name.to_lower()
	var category = get_parent().name.to_lower()
	
	if modifiable_part_of_setting is Range:
		if "Volume" in setting_name or "slider" in setting_name:
			var bus_name = setting_name.replace("Volume", "").replace("_slider", "").capitalize()
			SettingsData.loaded_data.settings[category][bus_name] = value
			var audio_bus = AudioServer.get_bus_index(bus_name)
			AudioServer.set_bus_volume_db(audio_bus, linear_to_db(value))
		else:
			#Add your cutom stuff here
			SettingsData.loaded_data.settings[category][setting_name] = value
	elif modifiable_part_of_setting is CheckButton:
		SettingsData.loaded_data.settings[category][setting_name] = value
	elif modifiable_part_of_setting is OptionButton:
		if "language" in setting_name:
			var locale = modifiable_part_of_setting.get_item_metadata(value)
			TranslationServer.set_locale(locale)
			SettingsData.loaded_data.settings[category]["current_locale"] = locale
		elif "resolution" in setting_name:
			#HACK: Doesn't handle proper window placement, just resolution selection
			SettingsData.loaded_data.settings[category]["resolution"] = value
		else:
			SettingsData.loaded_data.settings[category][setting_name] = value
	
	# Emit signal to notify parent that settings have changed
	#emit_signal("setting_changed", category, setting_name, value)


func populate_and_set_locale_button_item():
	var current_locale := TranslationServer.get_locale()
	var saved_locale_index := 0
	
	for locale:String in SettingsData.loaded_data.LOCALES:
		modifiable_part_of_setting.add_item(SettingsData.loaded_data.LOCALES[locale])
		modifiable_part_of_setting.set_item_metadata(modifiable_part_of_setting.get_item_count() - 1, locale)
		if current_locale.begins_with(locale):
			saved_locale_index = modifiable_part_of_setting.get_item_count() - 1
	
	modifiable_part_of_setting.select(saved_locale_index)

func populate_and_set_resolution_button_item():
	var window : Window = get_window()
	window.connect("size_changed", _preselect_resolution.bind(window))
	_update_ui()
	for resolution in GameSettingsSave.RESOLUTIONS_ARRAY:
		var resolution_string : String = "%d x %d" % [resolution.x, resolution.y]
		modifiable_part_of_setting.add_item(resolution_string)

func _update_ui(window : Window = get_window()) -> void:
	#%FullscreenButton.button_pressed = SettingsData.loaded_data.settings["video"]["fullscreen"]
	if !SettingsData.loaded_data.settings["video"]["fullscreen"]:
			var ws : Vector2 = SettingsData.loaded_data.settings["video"]["resolution"]
			window.size = ws
			var ss : Vector2 = DisplayServer.screen_get_size()
			window.position = ss*0.5-ws*0.5

	_preselect_resolution(window)
	_update_resolution_options_enabled()

func _preselect_resolution(window : Window) -> void:
	modifiable_part_of_setting.text = str(window.size)
	SettingsData.loaded_data.settings["video"]["resolution"] = window.size

func _update_resolution_options_enabled() -> void:
	#TODO: translation stuff
	if OS.has_feature("web"):
		modifiable_part_of_setting.disabled = true
		modifiable_part_of_setting.tooltip_text = "Disabled for web"
	elif SettingsData.loaded_data.settings["video"]["fullscreen"]:
		modifiable_part_of_setting.disabled = true
		modifiable_part_of_setting.tooltip_text = "Disabled for fullscreen"
	else:
		modifiable_part_of_setting.disabled = false
		modifiable_part_of_setting.tooltip_text = "Select a screen size"

func handle_locale_mismatch(current_locale: String) -> String:
	# Iterate through SettingsData.loaded_data.LOCALES and find a matching language code
	for locale:String in SettingsData.loaded_data.LOCALES:
		if current_locale.begins_with(locale):
			return locale
	
	#If no match is found, use the default locale
	return SettingsData.loaded_data.LOCALES.keys()[0]
