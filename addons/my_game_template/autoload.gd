extends Node
## This is not needed as you can use Engine.get_main_loop().current_scene.add_child() instead
static var tree : SceneTree

func _ready() -> void:
	tree = get_tree()
