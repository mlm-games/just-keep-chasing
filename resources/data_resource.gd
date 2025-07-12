class_name BaseData extends Resource

@export var id: String:
	get:
		if resource_name != "":
			return resource_name
		if resource_path.is_empty():
			return "Resource path is empty or not saved..."
		
		var temp_id = resource_path.get_file().trim_suffix(".tres")
		if id == "": 
			id = temp_id
		else:
			if Engine.is_editor_hint():
				if temp_id != "" and id != temp_id:
					id = temp_id
		resource_name = temp_id
		return id

@export var enabled := true
@export var unlocked := true

#TODO: Remove?
@export var local_to_scene : bool = false # Do not share stat upgrades


func duplicate_with_res_name(incl_subres:= false) -> BaseData:
	var dupli_res := duplicate(incl_subres)
	dupli_res.resource_name = resource_name
	return dupli_res
