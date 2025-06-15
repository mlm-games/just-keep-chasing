class_name Achievement extends Resource

var id: String:
	get: return resource_name.to_lower().replace(".tres", "")

@export var title: String
@export_multiline var description: String
@export var reward: String
@export var icon: Texture2D
@export_range(1, 10000000) var count_goal: float = 1.0

# Can be a string ("damage_dealt") or a Resource for more complex stats.
@export var stat_key: String # Variant Will work in 4.5 

@export var is_secret: bool = false
@export var is_active: bool = true # to be able to disable achievements without deleting them

#Managed by the achievement system, saved in user data

var current_progress: float = 0.0
var unlocked: bool = false
