class_name AugmentsData extends BaseData

@export_group("Display", "augment_")
@export var augment_icon : Texture2D # = Redacted texture like dungeons and gamblers?
@export var augment_price : int = 9999

@export_group("Data")
@export var stats_to_modify : Array[StatModifier]
@export var rarity : float = 1:
	set(val):
		rarity = clampf(val, 0, 1)
