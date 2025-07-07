extends Control

func _ready() -> void:
	%ExitButton.pressed.connect(STransitions.change_scene_with_transition.bind(ProjectSettings.get_setting("application/run/main_scene")))
	#%ExitButton.pressed.connect($PopupAnimator.animate_out.bind(queue_free)) #Crashes the game the second time
	$PopupAnimator.animate_in()
	%ExitButton.grab_focus()
