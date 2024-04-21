extends Node2D

func on_screen_notifier_screen_entered():
	for child in get_children():
		child.add_to_group("On Screen Enemies")
