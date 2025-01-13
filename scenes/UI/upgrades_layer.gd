extends CanvasLayer

var upgrade_scenes_path = "res://scenes/UI/health_slot.tscn" #tmp
@onready var hud : HUD = get_tree().get_first_node_in_group("HUD")
@onready var upgrade_slots_to_add_below_node: Control = %SpacerControl2

func _ready() -> void:
	get_tree().paused = true
	for i in range(3):
		var upgrade_slot = load(upgrade_scenes_path).instantiate()
		#upgrade_slot.augment = load(str(ResourceLoader.get_resource_uid(GameState.augments_paths.pick_random())))
		upgrade_slots_to_add_below_node.add_sibling(upgrade_slot)
		upgrade_slot.slot_clicked.connect(on_slot_clicked.bind(upgrade_slot))

func on_slot_clicked(slot):
	if GameState.research_points >= slot.augment.augment_price:
		GameState.research_points -= slot.augment.augment_price
		hud.update_currency_label()
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
