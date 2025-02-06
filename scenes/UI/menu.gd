extends Control

const WorldScene = "res://scenes/gameplay/world.tscn"
const SettingsScene = "res://scenes/UI/settings.tscn"
const AchievementsScene = "res://scenes/UI/achievements_screen.tscn"

@onready var btn_play = $MarginContainer/Control/VBoxContainer/PlayButton
@onready var btn_exit = $MarginContainer/Control/VBoxContainer/ExitButton
#Hack: hold r to restart, press r to reload

func _ready():
	GameState.load_settings(true)
	get_tree().paused = false
	# needed for gamepads to work
	btn_play.grab_focus()
	#if OS.has_feature('web'):
		#btn_exit.queue_free() # exit button dosn't make sense on HTML5
	GameState.reset_stats()

func _on_PlayButton_pressed() -> void:
	ScreenEffects.change_scene_with_transition(WorldScene)


func _on_ExitButton_pressed() -> void:
	# gently shutdown the game
	ScreenEffects.transition()
	await ScreenEffects.transition_player.animation_finished
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	ScreenEffects.change_scene_with_transition(SettingsScene)


func _on_achievements_button_pressed() -> void:
	ScreenEffects.change_scene_with_transition(AchievementsScene)
