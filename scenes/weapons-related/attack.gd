class_name Attack extends RefCounted

var attack_damage: float
var damage_over_time: float
var dot_duration: float
var dot_type: GameState.StatusEffectType

var crit_rate: float = 0
var crit_damage: float = 0 # 0 to 1, multiplies with damage
