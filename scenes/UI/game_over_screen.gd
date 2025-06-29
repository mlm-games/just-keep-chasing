extends Control

#@export var world_scene : PackedScene
func _ready() -> void:
	%RetryButton.grab_focus()
	%RetryButton.pressed.connect(_on_retry_button_pressed)

func _on_retry_button_pressed() -> void:
	STransitions.change_scene_with_transition("uid://c2gocuhw2o7py")
	
	print(CountStats.total_count_stats)
	print(CountStats.enemies_type_killed_stats)
	print(CountStats.augment_items_collection_stats)
	print(CountStats.guns_fired_by_type_stats)
	print(CountStats.powerup_collection_stats)
	
