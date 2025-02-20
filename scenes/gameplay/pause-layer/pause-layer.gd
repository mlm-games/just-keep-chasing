extends CanvasLayer
#FIXME: Replace fully in the futture by a better one
@onready var pause := self
@onready var pause_button := $MarginContainer/Control/PauseButton
@onready var resume_option := $MarginContainer/Control/VBoxOptions/Resume
@onready var pause_options := $MarginContainer/Control/VBoxOptions
@onready var color_rect := $ColorRect

@onready var nodes_grp1 := [pause_button] # should be visible during gamemplay and hidden during pause
@onready var nodes_grp2 := [pause_options, color_rect] # should be visible only in pause menu


func _ready() -> void:
	pause_hide()


func pause_show() -> void:
	for n:Node in nodes_grp1:
		n.hide()
	for n:Node in nodes_grp2:
		n.show()


func pause_hide() -> void:
	for n:Node in nodes_grp1:
		if n:
			n.show()

	for n:Node in nodes_grp2:
		if n:
			n.hide()


@warning_ignore("untyped_declaration")
func _unhandled_input(event) -> void:
	if event.is_action_pressed("pause"):
		if get_tree().paused:
			resume()
		else:
			pause_game()
		get_viewport().set_input_as_handled()


func resume() -> void:
	get_tree().paused = false
	pause_hide()


func pause_game() -> void:
	resume_option.grab_focus()
	get_tree().paused = true
	pause_show()


func _on_Resume_pressed() -> void:
	resume()


func _on_PauseButton_pressed() -> void:
	pause_game()


func _on_main_menu_pressed() -> void:
	if get_tree().paused:
		get_tree().paused = false
	ScreenEffects.change_scene_with_transition("res://scenes/UI/menu.tscn")
