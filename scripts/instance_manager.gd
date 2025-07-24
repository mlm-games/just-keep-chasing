class_name InstanceManager


static func new_projectile_instance(data: ProjectileData, shooter: BaseCharacter) -> BaseProjectile:
	if shooter is Player:
		data.projectile_damage *= CharacterStats.get_stat(CharacterStats.Stats.PLAYER_DAMAGE_MULT)
		data.projectile_damage += CharacterStats.get_stat(CharacterStats.Stats.RAW_DAMAGE_MOD)
		#@warning_ignore("narrowing_conversion")
		#data.projectile_range *= CharacterStats.get_stat(CharacterStats.Stats.TARGETTING_RANGE_MULT)
		#data.projectile_speed *=
	if shooter is BaseEnemy:
		data.projectile_damage += CharacterStats.get_stat(CharacterStats.Stats.RAW_GUN_ENEMY_DAMAGE_REDUCTION)
		data.projectile_damage *= CharacterStats.get_stat(CharacterStats.Stats.GUN_ENEMY_DAMAGE_MULT)
		#@warning_ignore("narrowing_conversion")
		#data.projectile_range *= CharacterStats.get_stat(CharacterStats.Stats.GUN_ENEMY_TARGETTING_RANGE_MULT)
	var instance : BaseProjectile = PoolManager.get_pool(data.base_scene).get_object()
	instance.projectile_data = data
	return instance
