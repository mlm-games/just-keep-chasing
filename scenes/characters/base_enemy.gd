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

@onready var visible_on_screen_notifier_2d: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

func _ready() -> void:
	visible_on_screen_notifier_2d.screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited)
	visible_on_screen_notifier_2d.screen_entered.connect(_on_visible_on_screen_notifier_2d_screen_entered)
	health_component.taking_damage.connect(func(dmg):
		CountStats.increment_stat(C.COUNT_STAT_KEYS.damage_dealt, int(dmg))
		#RunData.world.add_child(DamageNumbers.new_damage_text(dmg, parent_node.global_position))
		VFXSpawner.spawn_damage_number(dmg, global_position))
	CharacterStats.stat_changed.connect(_on_global_enemy_stat_changed)

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	add_to_group("On Screen Enemies")


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	remove_from_group("On Screen Enemies")

func _on_global_enemy_stat_changed(stat_key: CharacterStats.Stats, new_value: float):
	pass #TODO:health_component.update health with enemy max health
