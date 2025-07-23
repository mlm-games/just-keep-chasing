extends Control

func _ready() -> void:
	%RetryButton.grab_focus()
	%RetryButton.pressed.connect(_on_retry_button_pressed)

func _on_retry_button_pressed() -> void:
	STransitions.change_scene_with_transition(Menu.WorldScene)
	
	print(CountStats._all_stats)
