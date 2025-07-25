class_name Powerup extends PickUp
## Base powerup script

const BasePowerupScene : PackedScene = preload("uid://x2gb17exe2xq")

@export var data_resource : PowerupData

static func create_new_powerup(passed_data: PowerupData) -> Powerup:
	var powerup_instance : Powerup = PoolManager.get_pool(BasePowerupScene).get_object()
	powerup_instance.data_resource = passed_data
	return powerup_instance

func _ready() -> void:
	$CollisionShape2D.shape.radius = CharacterStats.get_stat(CharacterStats.Stats.POWERUP_PICKUP_RANGE)
	$Sprite2D.texture = data_resource.icon
	$Sprite2D.modulate = data_resource.icon_modulate
	$Sprite2D.scale = data_resource.icon_scale
	

func collect() -> void:
	RunData.powerup_collected(CollectionManager.get_resource_name(data_resource))
	World.I.use_powerup(CollectionManager.get_resource_name(data_resource)
	)
	
	CountStats.increment_stat(CountStats.get_stat_key(data_resource))
	
	PoolManager.get_pool(BasePowerupScene).release_object.bind(self)
	#Hack: Use the non button implementation, then make the powerup buttons unlockable by achievements.. 
