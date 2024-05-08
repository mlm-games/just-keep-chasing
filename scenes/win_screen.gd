extends Control

#@export var world_scene : PackedScene

func _ready():
	get_tree().paused = true

func _on_menu_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")


func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	hide()
	#get_parent().remove_child(self)
	#self.queue_free()
