extends Control

#@export var world_scene : PackedScene
func _ready() -> void:
	%RetryButton.grab_focus()
	GameState.research_points = 0

func _on_retry_button_pressed() -> void:
	ScreenEffects.change_scene_with_transition("res://scenes/UI/menu.tscn")
