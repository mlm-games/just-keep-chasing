class_name SlotContainer extends MarginContainer

signal slot_clicked
#FIXME: Pick based on spawn chance
@export var augment : Augments = load(GameState.collection_res.augments.values().pick_random())

var panel_entered : bool = false
var original_scale : Vector2
var hover_scale : Vector2 = Vector2(1.1, 1.1)
var hover_tween : Tween

@onready var display_price: int = augment.augment_price * GameState.price_multiplier

func _ready() -> void:
	original_scale = scale
	setup_slot()
	setup_hover_effects()
	pivot_offset = size / 2

func setup_slot() -> void:
	if augment != null:
		%TextureRect.texture = augment.augment_icon
		%UpgradeLabel.text = tr(augment.augment_id.capitalize())
		%PriceContainer.price_label.text = str(display_price)
		red_out_unbuyable_slots()

func setup_hover_effects() -> void:
	# Add a subtle shadow or glow effect
	var style_box = get_theme_stylebox("panel").duplicate()
	style_box.shadow_size = 4
	style_box.shadow_color = Color(0, 0, 0, 0.3)
	add_theme_stylebox_override("panel", style_box)

func red_out_unbuyable_slots() -> void:
	if display_price > GameState.research_points:
		%PriceContainer.price_label.modulate = Color(1.0, 0.333, 0.11)
		modulate = Color(0.7, 0.7, 0.7) # Dim the whole slot

func _on_panel_mouse_entered() -> void:
	panel_entered = true
	
	# Cancel any existing tween
	if hover_tween:
		hover_tween.kill()
	
	# Create new scale tween
	hover_tween = create_tween()
	hover_tween.set_trans(Tween.TRANS_CUBIC)
	hover_tween.set_ease(Tween.EASE_OUT).set_ignore_time_scale()
	hover_tween.tween_property(self, "scale", hover_scale, 0.1)
	
	# Fixme: Play hover sound
	#AudioManager.play_sfx("hover")

func _on_panel_mouse_exited() -> void:
	panel_entered = false
	
	# Cancel any existing tween
	if hover_tween:
		hover_tween.kill()
	
	# Create new scale tween
	hover_tween = create_tween()
	hover_tween.set_trans(Tween.TRANS_CUBIC)
	hover_tween.set_ease(Tween.EASE_OUT).set_ignore_time_scale()
	hover_tween.tween_property(self, "scale", original_scale, 0.1)

func _input(event: InputEvent) -> void:
	if panel_entered and event.is_pressed():
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			# Visual feedback for click
			var click_tween = create_tween()
			click_tween.set_trans(Tween.TRANS_CUBIC)
			click_tween.set_ease(Tween.EASE_OUT).set_ignore_time_scale()
			click_tween.tween_property(self, "scale", original_scale * 0.95, 0.1)
			click_tween.tween_property(self, "scale", hover_scale, 0.1)
			
			# FIXME: Play click sound
			#AudioManager.play_sfx("click")
			
			slot_clicked.emit()
			panel_entered = false
