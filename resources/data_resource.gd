class_name BaseData extends Resource

@export var id: String:
	get:
		if resource_name != "":
			return resource_name
		
		var temp_id = resource_path.get_slice("/", 1).trim_suffix(".tres")
		if id == "": 
			id = temp_id
		else:
			if Engine.is_editor_hint():
				if temp_id != "" and id != temp_id:
					id = temp_id
		return id

@export var local_to_scene : bool = false # Do not share stat upgrades
@export var enabled := true


#func _init() -> void:
	#id = 
