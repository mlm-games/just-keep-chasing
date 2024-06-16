extends CanvasLayer

var upgrade_scene = load("res://scenes/UI/health_slot.tscn") #tmp

@onready var upgrade_slots_to_add_below_node: Control = %SpacerControl2

func _ready() -> void:
	for i in range(3):
		var _upgrade_slot = upgrade_scene.instantiate()
		upgrade_slots_to_add_below_node.add_sibling(_upgrade_slot)
		_upgrade_slot.slot_clicked.connect(on_slot_clicked.bind(_upgrade_slot))

func on_slot_clicked(slot):
	apply_effect(slot.stats)
	
	slot.queue_free()
#TODO: Do it using augments...


func apply_effect(stats) -> void:
	for i in stats:
		GameState.player_max_health += stats[0].value
	print(GameState.player_max_health)
	
