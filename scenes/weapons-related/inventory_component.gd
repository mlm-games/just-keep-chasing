class_name InventoryComponent extends Node
# Even though it is a component, specific to this game (for managing guns)

signal gun_switched(new_gun_data: GunData)

var available_guns: Array[GunData] = []
var current_gun_index: int = 0

func _ready():
	# Populate with initially unlocked guns
	for gun_data: GunData in CollectionManager.all_guns.values():
		if gun_data.unlocked:
			add_gun(gun_data)

func add_gun(gun_data: GunData):
	if not available_guns.has(gun_data):
		available_guns.append(gun_data)

func switch_to_next_gun():
	if available_guns.size() <= 1: return

	current_gun_index = (current_gun_index + 1) % available_guns.size()
	gun_switched.emit(available_guns[current_gun_index])

func get_active_gun() -> GunData:
	if not available_guns.is_empty():
		return available_guns[current_gun_index]
	return null
