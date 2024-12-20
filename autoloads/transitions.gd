extends CanvasLayer

signal screen_covered

@onready var transition_player: AnimationPlayer = $TransitionRect/TransitionPlayer
@onready var transition_rect : ColorRect = $TransitionRect
@onready var white_rect : ColorRect = $OnScreenEffectsRect
@onready var effects_player: AnimationPlayer = $OnScreenEffectsRect/EffectsPlayer
@onready var shader_rect: ColorRect = $ShaderRect

func _ready():
	transition_rect.visible = false
	white_rect.visible = false
	shader_rect.visible = false

func change_scene_with_transition(scene_path: String, anim_name: String = "fadeToBlack", pop_up: bool = false):
	transition(anim_name)
	await screen_covered
	if !pop_up:
		get_tree().change_scene_to_file(scene_path)

func change_scene_with_transition_packed(scene: PackedScene, anim_name: String = "fadeToBlack"):
	transition(anim_name)
	await screen_covered
	get_tree().change_scene_to_packed(scene)

func transition(anim_name: String = "fadeToBlack", pop_up: bool = false):
	match anim_name:
		"fadeToBlack":
			transition_rect.visible = true
			transition_player.play(anim_name)
		"slightFlash":
			white_rect.visible = true
			effects_player.play(anim_name)
		"circleIn":
			shader_rect.visible = true
			transition_player.play(anim_name)
	if pop_up:
		pass



func _on_animation_player_animation_finished(anim_name: String):
	match anim_name:
		"fadeToBlack":
			screen_covered.emit()
			transition_player.play("fadeToNormal")
		"fadeToNormal":
			transition_rect.hide()
		"slightFlash":
			white_rect.hide()
		"circleIn":
			screen_covered.emit()
			transition_player.play("circleOut")
		"circleOut":
			shader_rect.hide()

func _input(_event: InputEvent) -> void:
	if transition_player.is_playing():
		get_viewport().set_input_as_handled()

#hack: insert no of cycles formula/ use frequency instead of duration for another function called smooth screen shake?
func screen_shake(duration: float, amplitude: float, camera: Camera2D = get_viewport().get_camera_2d()):
	var tween = create_tween()
	var original_position = camera.position
	for i in range(int(duration * 60)):  # Assuming 60 FPS
		var camera_offset = Vector2(randf() * amplitude * 2 - amplitude, 0)
		tween.tween_property(camera, "position", original_position + camera_offset, 1.0 / 60)  # Tween for 1 frame
	tween.tween_property(camera, "position", original_position, 1.0 / 60)  # Return to original position

func smooth_screen_shake(frequency: float, amplitude: float, camera: Camera2D = get_viewport().get_camera_2d()):
	var tween = create_tween()
	var original_position = camera.position
	var camera_offset = Vector2(randf() * amplitude * 2 - amplitude, randf() * amplitude * 2 - amplitude)
	tween.tween_property(camera, "position", original_position + camera_offset, 1/frequency)  
	tween.tween_property(camera, "position", original_position, 1/frequency)
