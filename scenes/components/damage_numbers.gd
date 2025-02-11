class_name DamageNumbers extends Label

const DISTANCE = 250

func display(damage: float, anim_time: float = 2.0, spread: float = PI/6) -> void:
	
	text = str(int(ceil(damage)))
	var movement = Vector2.UP.rotated(randf_range(-spread/2, spread/2)) * DISTANCE
	pivot_offset = size / 2
	scale += clamp(Vector2(damage/1000, damage/1000), Vector2.ONE/2,Vector2.ONE*3) 
	
	var tween = get_tree().create_tween().set_ease(Tween.EASE_OUT_IN).set_trans(Tween.TRANS_CUBIC)
	
	tween.tween_property(self, "position", position + movement, anim_time)
	tween.set_parallel(true)
	tween.tween_property(self, "scale", Vector2.ZERO, anim_time)
	tween.tween_property(self, "modulate:a", 0.0, anim_time)
	
	await tween.finished
	
	queue_free()
	
