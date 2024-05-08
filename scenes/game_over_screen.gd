extends Control

#@export var world_scene : PackedScene

func _ready() -> void:
	Transitions.circle_out()

func _on_retry_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")
