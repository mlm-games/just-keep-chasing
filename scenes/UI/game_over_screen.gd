extends Control

#@export var world_scene : PackedScene
func _ready() -> void:
	%RetryButton.grab_focus()
	%RetryButton.pressed.connect(_on_retry_button_pressed)

func _on_retry_button_pressed() -> void:
	STransitions.change_scene_with_transition("uid://c2gocuhw2o7py")
	
	print(CountStats._all_stats)
	
