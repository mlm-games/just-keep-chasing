extends Node

var ui_stack: Array = []
var hud: HUD

func push_layer(scene: PackedScene):
	if not ui_stack.is_empty():
		if ui_stack.back(): ui_stack.back().hide() # Hide the layer below or make it slightly transparent?
	
	var new_layer = scene.instantiate()
	ui_stack.append(new_layer)
	get_tree().get_first_node_in_group("PopupsRoot").add_child(new_layer)
	get_tree().paused = true # Pause the game when any UI is open

func pop_layer():
	if ui_stack.is_empty(): return
	
	ui_stack.pop_back().queue_free()
	
	if not ui_stack.is_empty():
		ui_stack.back().show() # Show the layer below
	else:
		get_tree().paused = false # Unpause if no UI is left
