class_name CurrencyDrop extends PickUp

const CURRENCY_VALUE = 1

var tween

func _ready() -> void:
	if tween: tween.kill()
	tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "global_position", global_position + 150*Vector2(randf_range(-1,1), randf_range(-1,1)), 0.75)
	
	

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		if tween: tween.kill()
		tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_parallel()
		tween.tween_property(self, "global_position", body.global_position, 0.15)
		tween.tween_property(self, "rotation_degrees", 720, 0.15)
		tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
		await tween.finished
		
		#TODO: play_audio()
		collect_currency()
		GameState.world.hud.update_currency_label()
		queue_free()

func collect_currency() -> void:
	GameState.research_points += 1
