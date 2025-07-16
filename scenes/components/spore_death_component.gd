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

	for i in burst_count:
		var projectile = burst_projectile_scene.instantiate()
		var angle = (float(i) / burst_count) * TAU
		
		projectile.projectile_data.projectile_speed = burst_speed
		projectile.global_position = owner.global_position
		projectile.rotation = angle
		
		projectiles_container.add_child(projectile)
