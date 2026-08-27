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
			VFXSpawner.spawn_damage_number(dmg, global_position)
			flash_sprite())
		health_component.entity_died.connect(_on_health_component_entity_died)
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

func flash_sprite(color: Color = Color.DARK_GOLDENROD, duration: float = 0.1) -> void:
	if not sprite_2d:
		return
	var original_mod := sprite_2d.modulate
	sprite_2d.modulate = color
	var tween := create_tween()
	tween.tween_property(sprite_2d, "modulate", original_mod, duration).set_ease(Tween.EASE_OUT)

func _on_health_component_entity_died() -> void:
	DropsSpawner.emit_mito_energy(global_position, mito_energy_value)
	CountStats.increment_stat(C.COUNT_STAT_KEYS.enemies_killed)
	CountStats.increment_stat(CountStats.get_stat_key(enemy_data_resource))
	StaticAudioManager.play_sound_varied(C.CommonSounds.EnemyHit)
	ScreenEffects.freeze_frame(0.07)

	remove_from_group("On Screen Enemies")
	remove_from_group("Enemies")
	var collision_shape := get_node_or_null("CollisionShape2D")
	if collision_shape:
		collision_shape.set_deferred("disabled", true)
	if hitbox_component:
		hitbox_component.set_deferred("monitoring", false)
		hitbox_component.set_deferred("monitorable", false)
	set_physics_process(false)

	if animation_component:
		animation_component.on_entity_died()

func _on_global_enemy_stat_changed(stat_key: CharacterStats.Stats, new_value: float) -> void:
	if not health_component or not enemy_data_resource:
		return
	match stat_key:
		CharacterStats.Stats.ENEMY_HEALTH_MULT, CharacterStats.Stats.FLAT_ENEMY_HEALTH_REDUCTION:
			var base_h := enemy_data_resource.base_health
			var mult := CharacterStats.get_stat(CharacterStats.Stats.ENEMY_HEALTH_MULT)
			var flat := CharacterStats.get_stat(CharacterStats.Stats.FLAT_ENEMY_HEALTH_REDUCTION)
			var new_max := maxf(1.0, (base_h * mult) - flat)
			var ratio := health_component.current_health / maxf(health_component.max_health, 1.0)
			health_component.initialize(new_max, false)
			health_component.current_health = new_max * ratio
			health_component.health_changed.emit(health_component.current_health)
