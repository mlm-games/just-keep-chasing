class_name AugmentsData extends BaseData

@export_group("Display", "augment_")
@export var augment_icon : Texture2D # = Redacted texture like dungeons and gamblers?
@export var augment_price : int = 9999
@export var rarity: C.RARITY = 0

@export_group("Data")
@export var stats_to_modify : Array[StatModifier]

@export_group("Description")
@export var auto_generate_description: bool = true
@export_multiline var custom_description: String
