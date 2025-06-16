class_name BaseEnemy extends BaseCharacter

var research_point_value : int

var health_mult: float = 1.0
var currency_mult: float = 1.0
# var currency_type: currency

@export var enemy_data_resource: EnemyData

func _ready() -> void:
	CharacterStats.stat_changed.connect(_on_global_enemy_stat_changed)

func _on_visible_on_screen_notifier_2d_screen_entered() -> void:
	add_to_group("On Screen Enemies")


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	remove_from_group("On Screen Enemies")

func _on_global_enemy_stat_changed(stat_key: CharacterStats.Stats, new_value: float):
	pass #TODO:health_component.update health with enemy max health
