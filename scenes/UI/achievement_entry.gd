class_name AchievementEntry extends PanelContainer

@onready var title: Label = $MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer/Title
@onready var description: Label = $MarginContainer/VBoxContainer/HBoxContainer2/VBoxContainer/Description
@onready var progress: Label = $MarginContainer/VBoxContainer/Progress
@onready var reward: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Reward
@onready var status: Label = $MarginContainer/VBoxContainer/HBoxContainer/VBoxContainer/Status
@onready var unlock_button: AnimButton = $MarginContainer/VBoxContainer/UnlockButton
@onready var progress_bar: ProgressBar = $MarginContainer/VBoxContainer/ProgressBar

var achievement: Achievement


func _ready() -> void:
	if not achievement:
		push_error("AchievementEntry: No achievement data set")
		return
	
	_update_display()


func _update_display() -> void:
	title.text = achievement.title
	description.text = achievement.description
	progress.text = "%d / %d" % [int(achievement.current_progress), int(achievement.count_goal)]
	reward.text = achievement.reward
	
	progress_bar.max_value = achievement.count_goal
	progress_bar.value = achievement.current_progress
	
	if achievement.unlocked:
		status.text = "Unlocked"
		unlock_button.disabled = true
		modulate = Color(1, 1, 1, 0.7)
	elif achievement.current_progress >= achievement.count_goal:
		status.text = "Ready to Claim!"
		unlock_button.disabled = false
	else:
		status.text = "In Progress"
		unlock_button.disabled = true


func update_achievement_progress() -> void:
	if not achievement:
		return
	
	progress_bar.value = achievement.current_progress
	progress.text = "%d / %d" % [int(achievement.current_progress), int(achievement.count_goal)]
	
	if achievement.current_progress >= achievement.count_goal:
		if achievement.unlocked:
			status.text = "Unlocked"
			unlock_button.disabled = true
		else:
			status.text = "Ready to Claim!"
			unlock_button.disabled = false


func _on_unlock_button_pressed() -> void:
	if not achievement:
		return
	
	if achievement.current_progress >= achievement.count_goal and not achievement.unlocked:
		var achievement_id = achievement.title.to_snake_case()
		BasicAchievements.unlock_achievement(achievement_id)
		_update_display()


func set_data(data_item: Achievement) -> void:
	achievement = data_item
	if is_inside_tree():
		_update_display()