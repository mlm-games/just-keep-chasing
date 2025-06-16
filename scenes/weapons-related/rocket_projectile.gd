class_name RocketProjectile extends BaseProjectile

# TODO: add an "aoe_data" export variable in projectile_data
@export var aoe_data: AreaOfEffectAttack

func _on_area_entered(body: Node2D) -> void:
	# Instead of dealing damage directly, we create an explosion
	explode()
	# The explosion will deal the damage, so the rocket itself doesn't need to.
	queue_free()

func explode():
	# Spawn the visual effect
	if aoe_data.explosion_vfx:
		var vfx = aoe_data.explosion_vfx.instantiate()
		get_parent().add_child(vfx)
		vfx.global_position = global_position

	# Find all hitbox components within the explosion radius
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = CircleShape2D.new()
	query.shape.radius = aoe_data.radius
	query.transform = Transform2D(0, global_position)
	query.collision_mask = self.collision_mask # Hit the same things the rocket would
	
	var hit_bodies = space_state.intersect_shape(query)
	
	for hit in hit_bodies:
		var body = hit.collider
		if body is HitboxComponent:
			var direction = (body.global_position - global_position).normalized()
			body.apply_knockback(direction, aoe_data.knockback_force, 0.2)
			var attack_data = Attack.new()
			attack_data.attack_damage = aoe_data.damage
			body.damage(attack_data)
