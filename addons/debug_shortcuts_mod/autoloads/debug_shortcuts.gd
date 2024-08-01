extends Node


func _ready():
	if OS.is_debug_build() == false:
		queue_free()

#like a cheat menu in palworld dev build


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.is_action_pressed("debug_fast_forward_game"):
			Engine.time_scale += 1
		if event.is_action_pressed("debug_slow_down_game"):
			Engine.time_scale -= 1
