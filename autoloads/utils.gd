class_name Utils extends Node

static func return_audio_at_pos(sound: AudioStream, global_pos: Vector2i) -> void:
	var player := AudioStreamPlayer2D.new()
	player.stream = sound
	player.bus = "Sfx"
	player.global_position = global_pos
