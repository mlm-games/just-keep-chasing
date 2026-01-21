class_name WinScreen extends Control

func _ready():
	STransitions.transition("circleOut")
	%ContinueButton.grab_focus()

func _on_menu_button_pressed() -> void:
	STransitions.change_scene_with_transition(Menu.MenuScene)


func _on_continue_button_pressed() -> void:
	UIManager.pop_layer()
	#A.tree.paused = false
	#get_parent().remove_child(self)
	#self.queue_free()
