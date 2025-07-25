class_name ChaserEnemy extends BaseMeleeEnemy
## A base for enemies that simply chase the player.
## Combines FollowTargetComponent with the base melee enemy logic.

@onready var follow_component: FollowTargetComponent = $FollowTargetComponent

func _ready() -> void:
	super._ready()
	if is_instance_valid(player):
		follow_component.target = player

func _physics_process(delta: float) -> void:
	super._physics_process(delta)
	
	follow_component.follow_target(velocity_component, data_resource.base_speed)
