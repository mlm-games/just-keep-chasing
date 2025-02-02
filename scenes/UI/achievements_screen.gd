class_name VirusEradicationGoalsEntry
extends Control

signal unlocked()

@onready var icon: TextureRect = %Icon
@onready var virus_eradication_goal_name: RichTextLabel = %VirusEradicationGoalsName
@onready var unlock_condition: RichTextLabel = %UnlockCondition
@onready var reward: RichTextLabel = %Reward
@onready var unlock_btn: Button = $PanelContainer/HBoxContainer/UnlockButton
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var icon_background: Panel = %IconBackground

@export var active_color := Color("#6eb86f")
@export var disabled_color := Color("#454545")
@export var reward_color := Color("#d4af37")
var virus_eradication_goals: VirusEradicationGoals


@onready var achievements_container = $PanelContainer/HBoxContainer/VBoxContainer/ScrollContainer/AchievementsContainer
@onready var achievement_label_template = preload("res://scenes/UI/achievement_entry.tscn")


class VirusEradicationGoals:
	pass

func _ready() -> void:
	#CountStats.stat_updated.connect(_check_achievements)
	#unlock_btn.pressed.connect(_on_unlocked)
	setup_achievements()
	#_setup_styles()
	
func setup_achievements() -> void:
	# Clear existing achievements
	for child in achievements_container.get_children():
		if child.name != "RichTextLabel":  # Keep the title
			child.queue_free()
	
	# Add achievement entries
	for achievement_id in AchievementsData.achievements:
		var achievement = AchievementsData.achievements[achievement_id]
		var entry = create_achievement_entry(achievement)
		achievements_container.add_child(entry)
		update_achievement_progress(entry, achievement_id)

func create_achievement_entry(achievement: Dictionary) -> Control:
	var entry = achievement_label_template.instantiate()
	entry.name = achievement.name
	
	# Set achievement details
	entry.get_node("MarginContainer/VBoxContainer/Title").text = achievement.name
	entry.get_node("MarginContainer/VBoxContainer/Description").text = achievement.description
	entry.get_node("MarginContainer/VBoxContainer/Reward").text = "Reward: " + achievement.reward
	
	# Setup progress bar
	var progress_bar = entry.get_node("MarginContainer/VBoxContainer/ProgressBar")
	progress_bar.min_value = 0
	progress_bar.max_value = achievement.required_value
	
	return entry

func update_achievement_progress(entry: Control, achievement_id: String) -> void:
	var achievement = AchievementsData.achievements[achievement_id]
	var current_value = get_achievement_progress(achievement_id)
	var progress_bar = entry.get_node("MarginContainer/VBoxContainer/ProgressBar")
	
	progress_bar.value = current_value
	
	# Update progress text
	var progress_label = entry.get_node("MarginContainer/VBoxContainer/Progress")
	progress_label.text = str(current_value) + " / " + str(achievement.required_value)
	
	# Update completion status
	if current_value >= achievement.required_value:
		entry.get_node("MarginContainer/VBoxContainer/Status").text = "✓ Completed"
		entry.modulate = Color(1, 1, 1, 0.6)

func get_achievement_progress(achievement_id: String) -> int:
	var achievement = AchievementsData.achievements[achievement_id]
	return CountStats.get_stat(achievement.stat_name)

func _on_stat_updated(_stat_name: String, _new_value: int) -> void:
	setup_achievements()  # Refresh all achievements


#
#func _check_achievements(_stat_name: String, _new_value: int) -> void:
	#for achievement_id in AchievementsData.achievements.keys():
		#if !virus_eradication_goals.unlocked and AchievementsData.check_achievement(achievement_id):
			## Achievement unlocked!
			#set_unlocked()

func _setup_styles() -> void:
	# Panel background
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	panel_style.border_color = Color(0.25, 0.25, 0.25)
	panel_style.border_width_left = 2
	panel_style.border_width_right = 2
	panel_style.border_width_top = 2
	panel_style.border_width_bottom = 2
	panel_style.corner_radius_top_left = 8
	panel_style.corner_radius_top_right = 8
	panel_style.corner_radius_bottom_left = 8
	panel_style.corner_radius_bottom_right = 8
	panel_style.shadow_color = Color(0, 0, 0, 0.3)
	panel_style.shadow_size = 4
	add_theme_stylebox_override("panel", panel_style)

	# Icon background
	var icon_bg_style = StyleBoxFlat.new()
	icon_bg_style.bg_color = Color(0.15, 0.15, 0.15)
	icon_bg_style.corner_radius_top_left = 6
	icon_bg_style.corner_radius_top_right = 6
	icon_bg_style.corner_radius_bottom_left = 6
	icon_bg_style.corner_radius_bottom_right = 6
	icon_background.add_theme_stylebox_override("panel", icon_bg_style)
	
	# Progress bar styling
	var bg_style = StyleBoxFlat.new()
	bg_style.bg_color = Color(0.15, 0.15, 0.15)
	bg_style.corner_radius_top_left = 3
	bg_style.corner_radius_top_right = 3
	bg_style.corner_radius_bottom_left = 3
	bg_style.corner_radius_bottom_right = 3
	progress_bar.add_theme_stylebox_override("background", bg_style)
	
	var fill_style = StyleBoxFlat.new()
	fill_style.bg_color = active_color
	fill_style.corner_radius_top_left = 3
	fill_style.corner_radius_top_right = 3
	fill_style.corner_radius_bottom_left = 3
	fill_style.corner_radius_bottom_right = 3
	progress_bar.add_theme_stylebox_override("fill", fill_style)

#func load_virus_eradication_goals(_virus_eradication_goals: VirusEradicationGoals) -> void:
	#virus_eradication_goals = _virus_eradication_goals
	#
	#var progress: float = clamp(GameState.check_virus_eradication_goals(virus_eradication_goals), 0.0, 1.0)
	#unlock_btn.disabled = progress < 1.0
	#progress_bar.value = progress * 100
	#
	#icon.texture = virus_eradication_goals.icon
	#virus_eradication_goals.text = "[b]%s[/b]" % virus_eradication_goals.name
	#unlock_condition.text = "[font_size=14]%s[/font_size]" % virus_eradication_goals.unlock_desc
	#reward.text = "[font_size=14][color=#%s]REWARD: %s[/color][/font_size]" % [reward_color.to_html(false), virus_eradication_goals.reward]
	#
	#_update_button_style()
	#if virus_eradication_goals.unlocked:
		#set_unlocked()

func _update_button_style():
	var button_style = StyleBoxFlat.new()
	button_style.corner_radius_top_left = 4
	button_style.corner_radius_top_right = 4
	button_style.corner_radius_bottom_left = 4
	button_style.corner_radius_bottom_right = 4
	button_style.bg_color = active_color if unlock_btn.disabled else active_color.darkened(0.2)
	button_style.border_color = active_color.darkened(0.3)
	unlock_btn.add_theme_stylebox_override("normal", button_style)
	
	var hover_style = button_style.duplicate()
	hover_style.bg_color = active_color.lightened(0.1)
	unlock_btn.add_theme_stylebox_override("hover", hover_style)
	
	var disabled_style = button_style.duplicate()
	disabled_style.bg_color = disabled_color
	unlock_btn.add_theme_stylebox_override("disabled", disabled_style)
#
#func set_unlocked() -> void:
	#unlock_btn.disabled = true
	#unlock_btn.text = "✓ Claimed"
	#modulate = Color(1, 1, 1, 0.6)
	#_update_button_style()
	#virus_eradication_goals.unlocked = true
#
#func is_unlockable() -> bool:
	#return !unlock_btn.disabled
#
#func _on_unlocked() -> void:
	#set_unlocked()
	#unlocked.emit()
	#create_tween().tween_property(self, "modulate", Color(1,1,1,0.6), 0.3)
