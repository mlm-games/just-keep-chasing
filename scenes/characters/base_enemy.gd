class_name BaseEnemy extends BaseCharacter
#TODO: save a animtion_library which will be used by default by enemies
var mito_energy_value : int

var health_mult: float = 1.0
var currency_mult: float = 1.0
# var currency_type: currency

@export var enemy_data_resource: EnemyData

@onready var health_component: HealthComponent = $HealthComponent
@onready var velocity_component: VelocityComponent = $VelocityComponent
@onready var animation_component: AnimationComponent = $AnimationComponent
@onready var hitbox_component: HitboxComponent = %EnemyHitboxComponent
@onready var sprite_2d: Sprite2D = $Sprite2D

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready() -> void:
	visible_on_screen_notifier_2d.screen_exited.connect(remove_from_group.bind("On Screen Enemies"))
	visible_on_screen_notifier_2d.screen_entered.connect(add_to_group.bind("On Screen Enemies"))
	health_component.taking_damage.connect(func(dmg):
		CountStats.increment_stat(C.COUNT_STAT_KEYS.damage_dealt, int(dmg))
		VFXSpawner.spawn_damage_number(dmg, global_position))
	CharacterStats.stat_changed.connect(_on_global_enemy_stat_changed)
	
	if is_instance_valid(sprite_2d.material):
		sprite_2d.material = sprite_2d.material.duplicate()

func shake(amount: float, duration: float):
	ScreenEffects.hit_shake()
	#ScreenEffects.shake(amount, duration)

func flash_sprite(color: Color = Color.DARK_GOLDENROD, duration: float = 0.1):
	pass
	#ScreenEffects.flash_sprite(owner.sprite, color, duration)


func _on_global_enemy_stat_changed(stat_key: CharacterStats.Stats, new_value: float):
	pass #TODO:health_component.update health with enemy max health
