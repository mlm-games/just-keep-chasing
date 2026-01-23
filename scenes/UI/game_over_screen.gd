extends Control

func _ready() -> void:
	%RetryButton.grab_focus()
	%RetryButton.pressed.connect(_on_retry_button_pressed)

func _on_retry_button_pressed() -> void:
	ScreenTransitions.change_scene_with_transition(C.SCREENS.WORLD)
	
	print(CountStats._all_stats)

#TODO: pretty print stats on screen
