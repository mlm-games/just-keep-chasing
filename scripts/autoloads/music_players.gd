extends Node

static var menu_audio := AudioStreamPlayer.new()
static var world_bgm_player := BGMPlayer.new()

func _ready() -> void:
	add_child(menu_audio)
	add_child(world_bgm_player)
