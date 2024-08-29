extends Control

@onready var btn_play = $MarginContainer/Control/VBoxContainer/PlayButton
@onready var btn_exit = $MarginContainer/Control/VBoxContainer/ExitButton
#Hack: hold r to restart, press r to reload

func _ready():
	# needed for gamepads to work
	btn_play.grab_focus()
	if OS.has_feature('web'):
		btn_exit.queue_free() # exit button dosn't make sense on HTML5


func _on_PlayButton_pressed() -> void:
	ScreenEffects.change_scene_with_transition("res://scenes/gameplay/world.tscn")


func _on_ExitButton_pressed() -> void:
	# gently shutdown the game
	ScreenEffects.transition()
	await ScreenEffects.transition_player.animation_finished
	get_tree().quit()
