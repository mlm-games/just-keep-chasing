class_name CurrencyDrop extends PickUp

@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

var currency_value : int = 1:
	get:
		return currency_value * int(CharacterStats.get_stat(CharacterStats.Stats.DROP_VALUE_MULTIPLIER))

var tween : Tween

func _ready() -> void:
	$CollisionShape2D.shape.radius = CharacterStats.get_stat(CharacterStats.Stats.CURRENCY_PICKUP_RANGE)
	
	tween = Juice.create_global_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "global_position", global_position + 150*Vector2(randf_range(-1,1), randf_range(-1,1)), 0.75)

func collect() -> void:
	StaticAudioM.play_sound_varied(preload("res://assets/sfx/hover.ogg"))
	RunData.mito_energy += currency_value
	
	CountStats.increment_stat("mito_energy_collected")
	
	queue_free()


func _process(delta: float) -> void:
	tween = create_tween()
