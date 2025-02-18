class_name DamageNumbers extends Label

const DISTANCE = 90

func display(damage: float, anim_time: float = 1.0, spread: float = PI/3) -> void:
	
	text = str(int(ceil(damage)))
	var movement : Vector2 = Vector2.UP.rotated(randf_range(-spread/2, spread/2)) * DISTANCE
	pivot_offset = size / 2
	scale += clamp(Vector2(damage/1000, damage/1000), Vector2.ONE/2,Vector2.ONE*3) 
	
	var tween : Tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(self, "position", position + movement, anim_time/2).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(self, "scale", Vector2.ONE, anim_time/2)
	tween.parallel().tween_property(self, "modulate:a", 1.0, anim_time/2)
	
	tween.tween_property(self, "scale", Vector2.ZERO, anim_time/2)
	tween.parallel().tween_property(self, "modulate:a", 0.0, anim_time/2)
	tween.tween_callback(self.queue_free)
	
