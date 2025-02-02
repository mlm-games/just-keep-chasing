class_name BaseData extends Resource

@export var id: String:
	get:
		if id.is_empty() and resource_path:
			id = resource_path.get_slice("/", -1).trim_suffix(".tres")
		return id
	set(value):
		id = value
