extends Node

const PAUSE_MENU_SCENE = preload("uid://3a2awiowcyww")

var ui_stack: Array[Node] = []
var pause_menu_instance: CanvasLayer = null


func _ready() -> void:
	# Pre-instantiate pause menu but don't add to tree yet
	pause_menu_instance = PAUSE_MENU_SCENE.instantiate()
	#FIXME: retry doesn't reset, and go to home doesn't work from winscreen?


func push_layer(scene: PackedScene) -> Node:
	if not ui_stack.is_empty():
		var current_layer = ui_stack.back()
		if is_instance_valid(current_layer):
			current_layer.hide()
	
	var new_layer = scene.instantiate()
	ui_stack.append(new_layer)
	
	var popups_root = A.tree.get_first_node_in_group("PopupsRoot")
	if popups_root:
		popups_root.add_child(new_layer)
	else:
		A.add_child(new_layer)
	
	A.tree.paused = true
	return new_layer


func pop_layer() -> void:
	if ui_stack.is_empty():
		return
	
	var layer_to_remove = ui_stack.pop_back()
	if is_instance_valid(layer_to_remove):
		layer_to_remove.queue_free()
	
	if not ui_stack.is_empty():
		var previous_layer = ui_stack.back()
		if is_instance_valid(previous_layer):
			previous_layer.show()
	else:
		A.tree.paused = false


func pop_all_layers() -> void:
	while not ui_stack.is_empty():
		pop_layer()


func pause() -> void:
	if not is_instance_valid(pause_menu_instance):
		pause_menu_instance = PAUSE_MENU_SCENE.instantiate()
	
	if pause_menu_instance.visible:
		return
	
	if not pause_menu_instance.is_inside_tree():
		A.add_child(pause_menu_instance)
	
	if pause_menu_instance.has_method("pause"):
		pause_menu_instance.pause()


func is_any_ui_open() -> bool:
	return not ui_stack.is_empty()
