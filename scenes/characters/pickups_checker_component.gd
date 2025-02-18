extends Node2D

func _on_hitbox_component_area_entered(area: Area2D) -> void:
	if area is PickUp:
	#match area:
		#Powerup:
			#Animation for collection of powerup
			var tween : Tween = get_tree().create_tween().set_ease(Tween.EASE_IN)
			tween.parallel().tween_property(area, "global_position", global_position, 0.15)
			tween.parallel().tween_property(area, "scale", Vector2.ZERO, 0.15)
			await tween.finished
			
			#TODO: play_audio()
			area.collect()
		#CurrencyDrop:
			#var tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_parallel()
			#tween.tween_property(area, "global_position", global_position, 0.15)
			#tween.tween_property(area, "rotation_degrees", 720, 0.15)
			#tween.tween_property(area, "scale", Vector2.ZERO, 0.15)
			#await tween.finished
			#
			##TODO: play_audio()
			#area.collect()
			#area.queue_free()
