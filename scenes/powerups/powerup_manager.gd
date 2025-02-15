class_name Powerup extends PickUp

@export var powerup_type : GameState.PowerupType

func _ready() -> void:
	$CollisionShape2D.shape.radius = GameStats.get_stat(GameStats.Stats.POWERUP_PICKUP_RANGE)

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		
		#Animation for collection of powerup
		var tween = get_tree().create_tween().set_ease(Tween.EASE_IN).set_parallel()
		tween.tween_property(self, "global_position", body.global_position, 0.15)
		tween.tween_property(self, "scale", Vector2.ZERO, 0.15)
		await tween.finished
		
		#TODO: play_audio()
		collect_powerup()
		queue_free()

func collect_powerup() -> void:
	GameState.powerup_collected(powerup_type)
	
	GameState.world.use_powerup(powerup_type)
	#Hack: Use the non button implementation, then make the powerup buttons unlockable by achievements.. 


func set_powerup_data(powerup_data:PowerupData) -> void:
	$Sprite2D.texture = powerup_data.icon
	$Sprite2D.modulate = powerup_data.icon_modulate
	$Sprite2D.scale = powerup_data.icon_scale
	powerup_type = powerup_data.powerup_type
