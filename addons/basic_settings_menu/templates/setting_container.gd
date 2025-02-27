@tool
extends HBoxContainer

@export var setting_name : StringName: # ="EXAMPLE_SETTING"
	set(name):
		setting_name = tr(name)
		if Engine.is_editor_hint(): label.text = setting_name

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
		

func set_initial_state():
	var setting_name = name.to_lower()
	var category = get_parent().name.to_lower()
	if modifiable_part_of_setting is OptionButton:
		modifiable_part_of_setting.select(modifiable_part_of_setting.get_item_metadata(SettingsData.loaded_data.settings[category][setting_name]))
	elif modifiable_part_of_setting is CheckButton:
		modifiable_part_of_setting.button_pressed = SettingsData.loaded_data.settings[category][setting_name]
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
