class_name UpgradesLayer extends CanvasLayer

const UpgradeScenePath = "uid://dq2rptl6lv3tc"
const UPGRADES_LAYER = "uid://24v2w4t8hgkl"
@onready var hud : HUD = RunData.hud
@onready var upgrade_slots_to_add_below_node: Control = %SpacerControl2

func _ready() -> void:
	RunData.is_in_shop = true
	
	StaticAudioM.play_sound_varied(preload("res://assets/sfx/hover.ogg"), -0.4, +10)
	
	var tween : Tween = get_tree().create_tween().set_parallel(true).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_ignore_time_scale()
	#tween.tween_property(Engine, "time_scale", 0.01, 0.25)
	tween.tween_property($Control, "modulate", Color.WHITE, 0.25)
	for i in range(3):
		var upgrade_slot : Node = load(UpgradeScenePath).instantiate()
		upgrade_slots_to_add_below_node.add_sibling(upgrade_slot)
		upgrade_slot.slot_clicked.connect(on_slot_clicked.bind(upgrade_slot))

func on_slot_clicked(slot: SlotContainer) -> void:
	slot.buy_if_rich_enough()
	red_out_unbuyable_slots()


func red_out_unbuyable_slots() -> void:
	for slot in %OptionsContainer.get_children():
		if slot is SlotContainer:
			slot.red_out_unbuyable_slots()

func _on_close_button_pressed() -> void:
	RunData.upgrade_shop_spawn_divisor += %OptionsContainer.get_child_count() / 2.0
	var tween : Tween = get_tree().create_tween().set_parallel(true).set_ease(Tween.EASE_IN).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_ignore_time_scale()
	tween.tween_property(Engine, "time_scale", 1, 0.1)
	tween.tween_property($Control, "modulate", Color.TRANSPARENT, 0.1)
	for slot in %OptionsContainer.get_children():
		if slot is SlotContainer:
			tween.tween_property(slot.point_light_2d, "energy", 0, 0.1)
			tween.tween_property(slot, "scale", Vector2.ZERO, 0.1)
	tween.set_parallel(false).tween_callback(UIManager.pop_layer)
	await tween.finished
	RunData.is_in_shop = false

static func new_upgrade_layer() -> UpgradesLayer:
	return load(UPGRADES_LAYER).instantiate()
