extends CanvasLayer

var upgrade : StatsModifier = load("res://scenes/misc/health.tres")
var upgrade_scene = load("res://scenes/UI/health_slot.tscn") #tmp
@onready var upgrade_slots_to_add_below_node: Control = %SpacerControl2

func _ready() -> void:
	for i in range(3):
		var _upgrade_slot = upgrade_scene.instantiate()
		#_upgrade_slot.connect(mouse_entered, _on_mouse_entered)
		upgrade_slots_to_add_below_node.add_sibling(_upgrade_slot)
		_upgrade_slot.slot_clicked.connect(on_slot_clicked.bind(_upgrade_slot))

func on_slot_clicked(slot):
	slot.hide()
	print("Hi")
