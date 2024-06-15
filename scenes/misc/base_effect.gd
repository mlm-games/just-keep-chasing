class_name StatsModifier extends Resource

@export var value : int = 0
@export var name: String = ""
@export var display_text: String = ""
@export var stats: Array[String] = []


func apply_effect() -> void:
	for i in stats:
		pass
