class_name PickupCheckerComponent extends Node2D

@export var hitbox_area : HitboxComponent

func _on_hitbox_component_area_entered(area: Area2D) -> void:
	if area is PickUp:
		var tween : Tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
		tween.parallel().tween_property(area, "global_position", global_position, 0.15)
		tween.parallel().tween_property(area, "scale", Vector2.ZERO, 0.15)
		tween.tween_callback(AudioManager.play_sound_varied.bind(C.CommonSounds.CurrencyCollected))
		tween.tween_callback(area.collect)
		
