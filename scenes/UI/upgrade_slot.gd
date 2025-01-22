class_name SlotContainer extends MarginContainer

signal slot_clicked

@export var augment : Augments = ResourceLoader.load(GameState.augments_paths.pick_random())

var panel_entered : bool = false

func _ready() -> void:
	if augment != null :
		%TextureRect.texture = augment.augment_icon
		%UpgradeLabel.text = tr(augment.augment_id.capitalize())
		%PriceContainer.price_label.text = str(augment.augment_price)
		red_out_unbuyable_slots()


func red_out_unbuyable_slots() -> void:
	if augment.augment_price > GameState.research_points:
		%PriceContainer.price_label.modulate = Color(1.0, 0.333, 0.11)

func _on_panel_mouse_entered() -> void:
	panel_entered = true


func _on_panel_mouse_exited() -> void:
	panel_entered = false

func _input(event: InputEvent) -> void:
	if panel_entered and event.is_pressed():
		slot_clicked.emit()
		panel_entered = false
