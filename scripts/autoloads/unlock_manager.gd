extends Node

func _ready() -> void:
	BasicAchievements.achievement_unlocked.connect(_on_achievement_unlocked)

func _on_achievement_unlocked(achievement: Achievement):
	if not achievement.unlock_resource:
		return
	
	var success: GameState.unlock_gun(achievement.unlock_resource)
	
	if success:
		print("Unlocked new content from achievement '%s': %s" % [achievement.title, resource_to_unlock.resource_path])
	
	#TODO: PopUpManager.show_unlock_notification(resource_to_unlock) ?
