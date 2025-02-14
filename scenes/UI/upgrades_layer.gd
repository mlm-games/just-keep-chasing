extends CanvasLayer

const UpgradeScenePath = "res://scenes/UI/upgrade_slot.tscn"
@onready var hud : HUD = get_tree().get_first_node_in_group("HUD")
@onready var upgrade_slots_to_add_below_node: Control = %SpacerControl2

func _ready() -> void:
	##Due to: When shop opens up, the gun fires too fast
	get_tree().get_first_node_in_group("Player").base_gun.unset_ignore_time_scale()
	
	var tween = get_tree().create_tween().set_parallel(true)
	tween.tween_property(Engine, "time_scale", 0.01, 0.25)
	tween.tween_property($Control, "modulate", Color.WHITE, 0.25)
	for i in range(3):
		var upgrade_slot = load(UpgradeScenePath).instantiate()
		upgrade_slots_to_add_below_node.add_sibling(upgrade_slot)
		upgrade_slot.slot_clicked.connect(on_slot_clicked.bind(upgrade_slot))

func on_slot_clicked(slot: SlotContainer):
	if GameState.research_points + GameStats.get_stat(GameStats.Stats.ITEM_LEND_THRESHOLD) >= slot.display_price:
		GameState.research_points -= slot.display_price
		hud.update_currency_label()
		GameState.apply_augment(slot.augment)
		slot.queue_free()
		# Increase the price multiplier after purchase
		GameState.price_multiplier *= (1 + GameState.price_increase_rate)
		
	red_out_unbuyable_slots()


func red_out_unbuyable_slots() -> void:
	for slot in %OptionsContainer.get_children():
		if slot is SlotContainer:
			slot.red_out_unbuyable_slots()

func _on_close_button_pressed() -> void:
	GameState.upgrade_shop_spawn_divisor += %OptionsContainer.get_child_count() * 5
	var tween = get_tree().create_tween().set_parallel(true).set_ease(Tween.EASE_OUT).set_ignore_time_scale()
	tween.tween_property(Engine, "time_scale", 1, 0.1)
	tween.tween_property($Control, "modulate", Color.TRANSPARENT, 0.1)
	await tween.finished
	hide()
