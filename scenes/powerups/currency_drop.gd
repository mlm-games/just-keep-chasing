class_name CurrencyDrop extends PickUp

const CURRENCY_VALUE = 1

var tween : Tween

func _ready() -> void:
	$CollisionShape2D.shape.radius = GameStats.get_stat(GameStats.Stats.CURRENCY_PICKUP_RANGE)
	if tween: tween.kill()
	tween = get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "global_position", global_position + 150*Vector2(randf_range(-1,1), randf_range(-1,1)), 0.75)

func collect() -> void:
	GameState.research_points += 1
	
	queue_free()
