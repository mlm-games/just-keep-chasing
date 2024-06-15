extends Control

#@export var world_scene : PackedScene

func _ready():
	get_tree().paused = true
	ScreenEffects.transition("circleOut")

func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	ScreenEffects.change_scene_with_transition("res://scenes/UI/menu.tscn")


func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	hide()
	#get_parent().remove_child(self)
	#self.queue_free()
