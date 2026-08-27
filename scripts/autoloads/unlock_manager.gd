extends Node

func _ready() -> void:
	BasicAchievements.achievement_unlocked.connect(_on_achievement_unlocked)

func _on_achievement_unlocked(achievement: Achievement) -> void:
	if not achievement.unlock_resource:
		return
	
	for res in achievement.unlock_resource:
		if res is GunData:
			GameState.unlock_gun(res)
		print("Unlocked new content from achievement '%s': %s" % [achievement.title, CollectionManager.get_resource_name(res)])
