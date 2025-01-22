extends Control

#@export var world_scene : PackedScene

func  _process(_delta: float) -> void:
	if get_tree().paused == false and visible:
		get_tree().paused = true

func _ready():
	get_tree().paused = true
	ScreenEffects.transition("circleOut")

func _on_menu_button_pressed() -> void:
	ScreenEffects.change_scene_with_transition("res://scenes/UI/menu.tscn")


func _on_continue_button_pressed() -> void:
	hide()
	get_tree().paused = false
	#get_parent().remove_child(self)
	#self.queue_free()
