class_name Powerup extends PickUp

const BasePowerupScene : PackedScene = preload("uid://x2gb17exe2xq")

@export var powerup_data : PowerupData

static func create_new_powerup(passed_data: PowerupData) -> Powerup:
	var powerup_instance : Powerup = BasePowerupScene.instantiate()
	powerup_instance.powerup_data = passed_data
	return powerup_instance

func _ready() -> void:
	$CollisionShape2D.shape.radius = GameStats.get_stat(GameStats.Stats.POWERUP_PICKUP_RANGE)
	$Sprite2D.texture = powerup_data.icon
	$Sprite2D.modulate = powerup_data.icon_modulate
	$Sprite2D.scale = powerup_data.icon_scale
	

func collect() -> void:
	GameState.powerup_collected(powerup_data.powerup_type)
	
	GameState.world.use_powerup(powerup_data.powerup_type)
	
	queue_free()
	#Hack: Use the non button implementation, then make the powerup buttons unlockable by achievements.. 
