extends CanvasLayer

var upgrade_scene = load("res://scenes/UI/health_slot.tscn") #tmp

@onready var upgrade_slots_to_add_below_node: Control = %SpacerControl2

func _ready() -> void:
	get_tree().paused = true
	for i in range(3):
		var _upgrade_slot = upgrade_scene.instantiate()
		upgrade_slots_to_add_below_node.add_sibling(_upgrade_slot)
		_upgrade_slot.slot_clicked.connect(on_slot_clicked.bind(_upgrade_slot))

func on_slot_clicked(slot):
	if GameState.research_points >= 5:
		GameState.research_points -= 5
		#apply_effect(slot.stats)
		slot.queue_free()
#TODO: Do it using augments...


#func apply_effect(stats) -> void:
	#for stat in stats:
		#match stat.key:
			#"max_health":
				#Player.max_health += stats[0].value
	#print(GameState.player_max_health)


func _input(event: InputEvent) -> void:
	if event.is_action("pause") and event.is_pressed():
		hide()


func _on_close_button_pressed() -> void:
	get_tree().paused = false
	hide()
