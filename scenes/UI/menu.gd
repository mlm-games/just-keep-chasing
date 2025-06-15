extends Control

const WorldScene = "uid://4fyoq8npekf0"
const SettingsScene = "uid://dp42fom7cc3n0"
const AchievementsScene = "uid://ckqthyukac8wf"

#Hack: hold r to restart, press r to reload
var tween: Tween
#TODO: The upgrade screen should only have stuff that is buyable (atleast once) with the money available. Also reduce the first buy to 0.5 and increase from there? or maybe reduce the prices and increase the multiplier?
func _ready() -> void:
	get_tree().paused = false
	# needed for gamepads to work
	%PlayButton.grab_focus()
	#if OS.has_feature('web'):
		#%ExitButton.queue_free() # exit button dosn't make sense on HTML5
	GameState.reset_game()
	run_title_anim()
	#run_buttons_anim()
	
	%PlayButton.pressed.connect(_on_PlayButton_pressed)
	%SettingsButton.pressed.connect(_on_settings_button_pressed)
	%AchievementsButton.pressed.connect(_on_achievements_button_pressed)
	%ExitButton.pressed.connect(_on_ExitButton_pressed)

func _on_PlayButton_pressed() -> void:
	ScreenEffects.transition("fadeToBlack", true)
	await ScreenEffects.transition_player.animation_finished
	get_tree().change_scene_to_file(WorldScene)
	ScreenEffects.transition("circleOut", false, 1.5)
	#await get_tree().create_timer(0.01).timeout


func _on_ExitButton_pressed() -> void:
	# gently shutdown the game
	ScreenEffects.transition()
	await ScreenEffects.transition_player.animation_finished
	get_tree().quit()


func _on_settings_button_pressed() -> void:
	ScreenEffects.change_scene_with_transition(SettingsScene)


func _on_achievements_button_pressed() -> void:
	ScreenEffects.change_scene_with_transition(AchievementsScene)

func run_title_anim() -> void:
	tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_parallel()
	tween.tween_property(%Title, "position:y", 117, 1.25).set_trans(Tween.TRANS_BACK)
	tween.tween_property(%Title, "position:x", get_viewport_rect().size.x/2 - 300, 1.25) # Need to find a better way
	tween = tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE).set_parallel(false)
	tween.tween_property(%Title.material, "shader_parameter/bounce_height", 0, 1)
	tween.tween_property(%Title, "position:x", get_viewport_rect().size.x/2 - 325, 1.25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC).set_delay(5) # Need to find a better way
