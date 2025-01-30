class_name BaseData extends Resource

@export var id: String = resource_path.get_slice("/", -1).trim_suffix(".tres")
