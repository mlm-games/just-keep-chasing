class_name VirusEradicationGoalsEntry
extends Control

signal unlocked()
#
#@onready var icon: TextureRect = %Icon
#@onready var virus_eradication_goal_name: RichTextLabel = %VirusEradicationGoalsName
#@onready var unlock_condition: RichTextLabel = %UnlockCondition
#@onready var reward: RichTextLabel = %Reward
#@onready var icon_background: Panel = %IconBackground

#@export var active_color := Color("#6eb86f")
#@export var disabled_color := Color("#454545")
#@export var reward_color := Color("#d4af37")
#var virus_eradication_goals: VirusEradicationGoals


@onready var achievements_container = $PanelContainer/HBoxContainer/MarginContainer/VBoxContainer/ScrollContainer/AchievementsContainer
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
	entry.get_node("MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer/Title").text = achievement.name
	entry.get_node("MarginContainer/VBoxContainer//HBoxContainer2/VBoxContainer/Description").text = achievement.description
	entry.get_node("MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Reward").text = "Reward: " + achievement.reward
	
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
