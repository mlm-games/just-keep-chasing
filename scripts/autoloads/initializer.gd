extends Node


func _ready() -> void:
	GameState.update_achievements()
	GameState.load_game()
