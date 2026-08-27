class_name SporeDeathComponent extends Node

@export var burst_projectile_scene: PackedScene
@export var burst_count: int = 8
@export var burst_speed: float = 250.0

func _ready():
	var health_comp = owner.get_node("HealthComponent")
	if health_comp:
		health_comp.entity_died.connect(_on_entity_died)

func _on_entity_died():
	var projectiles_container = A.tree.get_first_node_in_group("ProjectilesContainer")
	if not projectiles_container: return

	var pdata := ProjectileData.new()
	pdata.projectile_speed = burst_speed
	pdata.projectile_range = 600
	pdata.projectile_damage = 8.0
	pdata.projectile_spread = 5.0
	pdata.collision_shape_mask = 2
	pdata.lifespan_time = 2.0
	pdata.projectile_aoe_data = AreaOfEffectAttack.new()

	for i in burst_count:
		var projectile = burst_projectile_scene.instantiate()
		var angle = (float(i) / burst_count) * TAU

		projectile.projectile_data = pdata
		projectiles_container.add_child(projectile)
		projectile.global_position = owner.global_position
		projectile.rotation = angle
