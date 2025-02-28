class_name AchievementEntry extends PanelContainer

@onready var title: Label = $MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer/Title
@onready var description: Label = $MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer/Description
@onready var progress: Label = $MarginContainer/VBoxContainer/Progress
@onready var reward: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Reward
@onready var status: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Status
@onready var unlock_button: AnimButton = $MarginContainer/VBoxContainer/UnlockButton
@onready var progress_bar: ProgressBar = $MarginContainer/VBoxContainer/ProgressBar

var achievement : BasicAchievements.Achievement

#func _init(achievement: BasicAchievements.Achievement) -> void:
	#self.achievement = achievement

func _ready() -> void:
	title.text = achievement.name
	description.text = achievement.description
	progress.text = str(achievement.current_progress) + " / " + str(achievement.count_goal)
	reward.text = achievement.reward
	status.text = "Unlocked" if achievement.unlocked else "Not Unlocked"
	unlock_button.disabled = false if achievement.unlocked else true
	progress_bar.max_value = achievement.count_goal
	progress_bar.value = achievement.current_progress

func update_achievement_progress() -> void:
	progress_bar.value = achievement.current_progress
	unlock_button.disabled = false if achievement.unlocked else true
	
	# Update progress text
	progress.text = str(achievement.current_progress) + " / " + str(achievement.count_goal)
	
	# Update completion status
	if achievement.current_progress >= achievement.count_goal:
		status.text = "✓ Completed"
		modulate = Color(1, 1, 1, 0.6)
