class_name BaseCharacterData extends BaseData

@export_group("Stats", "base_")
@export var base_health : float = 0
@export var base_speed : float = 0


@export var modifiers: Array[StatModifier] = []


# Current values calculated from base + modifiers
var current_health: float
var current_speed: float


func apply_modifier(modifier: StatModifier) -> void:
	modifiers.append(modifier)
	recalculate_stats()

func recalculate_stats() -> void:
	# Reset to base values
	current_health = base_health
	current_speed = base_speed
	
	# Apply all modifiers
	for mod in modifiers:
		GameState.apply_stat_modifier(mod)
