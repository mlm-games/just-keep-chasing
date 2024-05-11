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

func change_scene_with_transition(anim_name: String,scene_path: String):
	transition(anim_name)
	await screen_covered
	get_tree().change_scene_to_file(scene_path)

func change_scene_with_transition_packed(anim_name: String,scene: PackedScene):
	transition(anim_name)
	await screen_covered
	get_tree().change_scene_to_packed(scene)

func transition(anim_name):
	match anim_name:
		"fadeToBlack":
			transition_rect.visible = true
			transition_player.play(anim_name)
		"slightFlash":
			white_rect.visible = true
			effects_player.play(anim_name)
		"circle-in":
			transition_rect.visible = true
			transition_player.play(anim_name)


func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"fadeToBlack":
			screen_covered.emit()
			transition_player.play("fadeToNormal")
		"fadeToNormal":
			transition_rect.hide()
			get_tree().paused = false
		"slightFlash":
			white_rect.hide()
		"circleIn":
			screen_covered.emit()
			transition_player.play("circleOut")
		"circleOut":
			shader_rect.hide()
			get_tree().paused = false

func _input(_event: InputEvent) -> void:
	if transition_player.is_playing():
		get_viewport().set_input_as_handled()

func screen_shake(duration: float, amplitude: float, camera: Camera2D):
	var tween = create_tween()
	var original_position = camera.position
	for i in range(int(duration * 60)):  # Assuming 60 FPS
		var offset = Vector2(randf() * amplitude * 2 - amplitude, 0)
		tween.tween_property(camera, "position", original_position + offset, 1.0 / 60)  # Tween for 1 frame
	tween.tween_property(camera, "position", original_position, 1.0 / 60)  # Return to original position
