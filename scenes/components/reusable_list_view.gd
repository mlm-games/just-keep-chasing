class_name ReusableListView extends VBoxContainer

@export var item_scene: PackedScene

func populate(data_array: Array):
	# Clear existing items
	for child in get_children():
		child.queue_free()
		
	# Create new items
	for data_item in data_array:
		var item_instance = item_scene.instantiate()
		#NOTE: All item scenes should have a 'set_data' function
		item_instance.set_data(data_item) 
		add_child(item_instance)
