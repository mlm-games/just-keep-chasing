class_name CurrencyDrop extends PickUp #Simpler duplicate

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var currency_value : int = 1:
	get:
		return currency_value * int(CharacterStats.get_stat(CharacterStats.Stats.DROP_VALUE_MULTIPLIER))

var spawn_tween : Tween
var loop_tween : Tween

func _ready() -> void:
	$CollisionShape2D.shape.radius = CharacterStats.get_stat(CharacterStats.Stats.CURRENCY_PICKUP_RANGE)
	
	spawn_tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	spawn_tween.tween_property(self, "global_position", global_position + 150*Vector2(randf_range(-1,1), randf_range(-1,1)), 0.75)
	
	loop_tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_loops()
	loop_tween.tween_property(%PointLight2D, "energy", 0.1, 1)
	loop_tween.parallel().tween_property(%Sprite2D, "rotation", 0.5, 5)
	loop_tween.tween_property(%PointLight2D, "energy", 0.2, 1)
	loop_tween.parallel().tween_property(%Sprite2D, "rotation", 0.0, 5)

func collect() -> void:
	StaticAudioM.play_sound_varied(preload("res://assets/sfx/hover.ogg"))
	RunData.mito_energy += currency_value
	
	CountStats.increment_stat("mito_energy_collected")
	
	PoolManager.get_pool(DropsSpawner.LoadedCurrencyScene).release_object.bind(self)
