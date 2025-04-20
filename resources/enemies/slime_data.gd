class_name EnemyData extends BaseCharacterData

@export var base_enemy_scene : PackedScene

@export var base_contact_damage : float = 0
@export var research_point_value : int = int(NAN)
@export var enemy_spawn_chance : float = 1
@export var enemy_spawn_order : int = 1

@export_group("Character Properties", "character_")
@export var character_hitbox_shape_type : Shape2D = RectangleShape2D.new()
@export var character_hitbox_shape_value : Vector2 = Vector2(44, 40)
@export var character_scale : Vector2 = Vector2.ONE

@export_group("Sprite Properies", "sprite_")
@export var sprite_texture : Texture2D
@export var sprite_scale : Vector2 = Vector2(0.06, 0.057)
@export var sprite_color : Color = Color.WHITE

@export var gun: GunData 

static var spawnable_enemies: Dictionary[int, EnemyData] = {} #key: spawn_range, value: Enemydata
static var enemy_spawn_type_range := Vector2i(1, 1)


static func get_random_by_spawn_chance() -> EnemyData:
	#TODO: Replace randfs in the powertype scene or script (as a static fn?) itself or implement a better version
	var enemy_data: EnemyData = spawnable_enemies[randi_range(enemy_spawn_type_range.x, enemy_spawn_type_range.y)]
	if enemy_data.enemy_spawn_chance < randf():
		enemy_data = get_random_by_spawn_chance()
	return enemy_data

static func spawn_enemy(enemy_data: EnemyData, global_pos: Vector2) -> SlimeEnemy:
	var enemy_scene : PackedScene = enemy_data.base_enemy_scene
	var enemy_instance:SlimeEnemy = enemy_scene.instantiate()
	enemy_instance.set_data_values(enemy_data)
	enemy_instance.get_node("HealthComponent").max_health *= GameStats.get_stat(GameStats.Stats.ENEMY_HEALTH_MULT)
	enemy_instance.global_position = global_pos
	return enemy_instance
