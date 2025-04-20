class_name BaseData extends Resource

@export var id: String:
	get: return resource_path.get_slice("/", 1).trim_suffix(".tres")
@export var local_to_scene : bool = false # Do not share stat upgrades
@export var enabled := true


#func _init() -> void:
	#id = 
