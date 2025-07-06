extends Control

const WorldScene = "uid://4fyoq8npekf0"
const SettingsScene = "uid://dp42fom7cc3n0"
const AchievementsScene = "uid://ckqthyukac8wf"

@onready var buttons_container: VBoxContainer = %ButtonsContainer

#Hack: hold r to restart, press r to reload
var tween: Tween

func _ready() -> void:
	get_tree().paused = false
	# needed for gamepads to work
	%PlayButton.grab_focus()
	#if OS.has_feature('web'):
		#%ExitButton.queue_free() # exit button dosn't make sense on HTML5
	run_title_anim()
	run_buttons_anim()
	
	%PlayButton.pressed.connect(_on_PlayButton_pressed)
	%SettingsButton.pressed.connect(add_child.bind(preload(SettingsScene).instantiate()))
	%AchievementsButton.pressed.connect(STransitions.change_scene_with_transition.bind(AchievementsScene))
	%CreditsButton.pressed.connect(add_child.bind(preload("uid://bq0gelfcjnqvg").instantiate()))
	%ExitButton.pressed.connect(_on_ExitButton_pressed)

func _on_PlayButton_pressed() -> void:
	STransitions.transition("fadeToBlack", true)
	await STransitions.transition_player.animation_finished
	STransitions.transition("circleOut", false, 1.5)
	get_tree().change_scene_to_file(WorldScene)
	#await get_tree().create_timer(0.01).timeout


func _on_ExitButton_pressed() -> void:
	# gently shutdown the game
	STransitions.transition()
	await STransitions.transition_player.animation_finished
	get_tree().quit()


func run_title_anim() -> void:
	tween = get_tree().create_tween().set_trans(Tween.TRANS_SINE).set_parallel()
	tween.tween_property(%Title, "position:y", 117, 1.25).set_trans(Tween.TRANS_BACK)
	tween.tween_property(%Title, "position:x", get_viewport_rect().size.x/2 - 300, 1.25) # Need to find a better way
	tween = tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BOUNCE).set_parallel(false)
	tween.tween_property(%Title.material, "shader_parameter/bounce_height", 0, 1)
	tween.tween_property(%Title, "position:x", get_viewport_rect().size.x/2 - 325, 1.25).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_ELASTIC).set_delay(5) # Need to find a better way


func run_buttons_anim() -> void:
	tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BOUNCE).set_parallel(false)
	tween.tween_property(%ButtonsContainer, "position:y", 248 , 1.25).from(800)
