class_name AchievementsScreen
extends Control

signal unlocked()

@onready var achievement_label_template := load("uid://ba8wjuxwmjiug")


func _ready() -> void:
	# Get all achievement data
	var all_achievements = BasicAchievements.get_all_achievements()
	# Tell the list view to populate itself
	%AchievementsListView.populate(all_achievements) 
	%BackButton.grab_focus()


func _on_back_button_pressed() -> void:
	ScreenEffects.change_scene_with_transition(ProjectSettings.get_setting("application/run/main_scene"))
