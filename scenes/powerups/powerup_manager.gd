class_name Powerup extends PickUp
## Base powerup script

const BasePowerupScene : PackedScene = preload("uid://x2gb17exe2xq")

@export var powerup_data : PowerupData

static func create_new_powerup(passed_data: PowerupData) -> Powerup:
	var powerup_instance : Powerup = BasePowerupScene.instantiate()
	powerup_instance.powerup_data = passed_data
	return powerup_instance

func _ready() -> void:
	$CollisionShape2D.shape.radius = CharacterStats.get_stat(CharacterStats.Stats.POWERUP_PICKUP_RANGE)
	$Sprite2D.texture = powerup_data.icon
	$Sprite2D.modulate = powerup_data.icon_modulate
	$Sprite2D.scale = powerup_data.icon_scale
	

func collect() -> void:
	RunData.powerup_collected(CollectionManager.get_resource_name(powerup_data))
	RunData.world.use_powerup(CollectionManager.get_resource_name(powerup_data)
	)
	
	CountStats.powerup_collection_stats[CountStats.get_stat_key(powerup_data)] += 1
	
	queue_free()
	#Hack: Use the non button implementation, then make the powerup buttons unlockable by achievements.. 
