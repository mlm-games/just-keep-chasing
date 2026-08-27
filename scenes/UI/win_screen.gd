class_name WinScreen extends Control

signal continue_pressed

func _ready():
	ScreenTransitions.transition("circleOut")
	%ContinueButton.grab_focus()

func _on_menu_button_pressed() -> void:
	A.tree.paused = false
	UIManager.pop_all_layers()
	ScreenTransitions.change_scene_with_transition(C.SCREENS.MENU)


func _on_continue_button_pressed() -> void:
	continue_pressed.emit()
	UIManager.pop_layer()
