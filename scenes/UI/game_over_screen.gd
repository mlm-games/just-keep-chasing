extends Control

#@export var world_scene : PackedScene
func _ready() -> void:
	%RetryButton.grab_focus()

func _on_retry_button_pressed() -> void:
	ScreenEffects.change_scene_with_transition("uid://c2gocuhw2o7py")
