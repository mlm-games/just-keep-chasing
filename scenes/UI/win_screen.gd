class_name WinScreen extends Control

func _ready():
	ScreenTransitions.transition("circleOut")
	%ContinueButton.grab_focus()

func _on_menu_button_pressed() -> void:
	ScreenTransitions.change_scene_with_transition(C.SCREENS.MENU)


func _on_continue_button_pressed() -> void:
	UIManager.pop_layer()
	#A.tree.paused = false
	#get_parent().remove_child(self)
	#self.queue_free()
