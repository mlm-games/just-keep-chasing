# gun_selection_ui.gd
extends Control

func _ready() -> void:
	populate_gun_list()

func populate_gun_list() -> void:
	for gun in RunData.world.guns:
		var button = Button.new()
		button.text = gun.name
		if GameState.is_gun_unlocked(gun.resource_path):
			button.disabled = true
			button.text += " (Unlocked)"
		else:
			button.pressed.connect(start_trial.bind(gun))
		add_child(button)

func start_trial(gun: PackedScene) -> void:
	get_parent().start_gun_trial(gun)
