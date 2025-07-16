class_name WinScreen extends Control

#@export var world_scene : PackedScene


func _ready():
	STransitions.transition("circleOut")

func _on_menu_button_pressed() -> void:
	STransitions.change_scene_with_transition("uid://c2gocuhw2o7py")


func _on_continue_button_pressed() -> void:
	UIManager.pop_layer()
	#A.tree.paused = false
	#get_parent().remove_child(self)
	#self.queue_free()
