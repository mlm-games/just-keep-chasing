class_name BaseEnemy extends BaseCharacter

var mito_energy_value : int
var health_mult: float = 1.0
var currency_mult: float = 1.0
var base_sprite_scale: Vector2 = Vector2.ONE

@export var enemy_data_resource: EnemyData

@onready var health_component: HealthComponent = get_node_or_null("HealthComponent")
@onready var velocity_component: VelocityComponent = get_node_or_null("VelocityComponent")
@onready var animation_component: AnimationComponent = get_node_or_null("AnimationComponent")
@onready var hitbox_component: HitboxComponent = get_node_or_null("%EnemyHitboxComponent")
@onready var sprite_2d: Sprite2D = get_node_or_null("Sprite2D")
@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = get_node_or_null("VisibleOnScreenNotifier2D")

func _ready() -> void:
	if visible_on_screen_notifier_2d:
		visible_on_screen_notifier_2d.screen_exited.connect(remove_from_group.bind("On Screen Enemies"))
		visible_on_screen_notifier_2d.screen_entered.connect(add_to_group.bind("On Screen Enemies"))
	if health_component:
		health_component.taking_damage.connect(func(dmg):
			CountStats.increment_stat(C.COUNT_STAT_KEYS.damage_dealt, int(dmg))
			VFXSpawner.spawn_damage_number(dmg, global_position))
	CharacterStats.stat_changed.connect(_on_global_enemy_stat_changed)

	if sprite_2d and is_instance_valid(sprite_2d.material):
		sprite_2d.material = sprite_2d.material.duplicate()

	_apply_enemy_data()


func _apply_enemy_data() -> void:
	if not enemy_data_resource:
		return

	if health_component:
		health_component.initialize(enemy_data_resource.base_health)
	mito_energy_value = enemy_data_resource.mito_energy_value
	scale = enemy_data_resource.character_scale

	if sprite_2d:
		if enemy_data_resource.sprite_texture:
			sprite_2d.texture = enemy_data_resource.sprite_texture
		base_sprite_scale = enemy_data_resource.sprite_scale
		sprite_2d.scale = base_sprite_scale
		sprite_2d.modulate = enemy_data_resource.sprite_color

func shake(amount: float, duration: float):
	ScreenEffects.hit_shake()

func flash_sprite(color: Color = Color.DARK_GOLDENROD, duration: float = 0.1):
	pass

func _on_global_enemy_stat_changed(stat_key: CharacterStats.Stats, new_value: float):
	pass
