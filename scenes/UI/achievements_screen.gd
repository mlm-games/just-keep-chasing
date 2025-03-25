class_name VirusEradicationGoalsEntry
extends Control

signal unlocked()

@onready var achievements_container := %AchievementsContainer
@onready var achievement_label_template := load("uid://ba8wjuxwmjiug")


func _ready() -> void:
	setup_achievements()
	#_setup_styles()
	
func setup_achievements() -> void:

	# Add achievement entries
	for achievement_id:StringName in BasicAchievements.achievements:
		var achievement : Achievement = BasicAchievements.achievements[achievement_id]
		
		BasicAchievements.update_achievement(achievement_id, CountStats.get_stat(BasicAchievements.achievements[achievement_id].stat_key))
		
		var entry : AchievementEntry = achievement_label_template.instantiate()
		entry.achievement = achievement
		achievements_container.add_child(entry)
		entry.update_achievement_progress()


func _on_back_button_pressed() -> void:
	ScreenEffects.change_scene_with_transition(ProjectSettings.get_setting("application/run/main_scene"))
