class_name CurrencyDrop extends PickUp

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var currency_value : int = 1:
	get:
		return currency_value * int(GameStats.get_stat(GameStats.Stats.DROP_VALUE_MULTIPLIER))

var tween : Tween

func _ready() -> void:
	$CollisionShape2D.shape.radius = GameStats.get_stat(GameStats.Stats.CURRENCY_PICKUP_RANGE)
	if tween: tween.kill()
	tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "global_position", global_position + 150*Vector2(randf_range(-1,1), randf_range(-1,1)), 0.75)

func collect() -> void:
	audio_stream_player.reparent(get_tree().get_root())
	audio_stream_player.play()
	GameState.research_points += currency_value
	
	CountStats.total_count_stats["essence_collected"] += currency_value
	
	queue_free()
