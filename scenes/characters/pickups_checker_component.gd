extends Node2D

func _on_hitbox_component_area_entered(area: Area2D) -> void:
	if area is PickUp:
		var tween : Tween = get_tree().create_tween().set_ease(Tween.EASE_IN)
		tween.parallel().tween_property(area, "global_position", global_position, 0.15)
		tween.parallel().tween_property(area, "scale", Vector2.ZERO, 0.15)
		await tween.finished
		
		#TODO: play_audio()
		area.collect()
		
