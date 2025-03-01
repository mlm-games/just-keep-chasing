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


@onready var achievements_container = %AchievementsContainer
@onready var achievement_label_template = load("res://scenes/UI/achievement_entry.tscn")


func _ready() -> void:
	setup_achievements()
	#_setup_styles()
	
func setup_achievements() -> void:

	# Add achievement entries
	for achievement_id in BasicAchievements.achievements:
		var achievement = BasicAchievements.achievements[achievement_id]
		var entry : AchievementEntry = achievement_label_template.instantiate()
		entry.achievement = achievement
		achievements_container.add_child(entry)
		entry.update_achievement_progress()


func _on_back_button_pressed() -> void:
	ScreenEffects.change_scene_with_transition(ProjectSettings.get_setting("application/run/main_scene"))
