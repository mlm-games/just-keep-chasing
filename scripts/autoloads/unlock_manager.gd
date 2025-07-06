extends Node

func _ready() -> void:
	BasicAchievements.achievement_unlocked.connect(_on_achievement_unlocked)

func _on_achievement_unlocked(achievement: Achievement):
	if not achievement.unlock_resource:
		return
	
	for res in achievement.unlock_resource:
		GameState.unlock_gun(res)
	
	#if success:
		print("Unlocked new content from achievement '%s': %s" % [achievement.title, CollectionManager.get_resource_name(res)])
	
	#TODO: PopUpManager.show_unlock_notification(resource_to_unlock) ?
