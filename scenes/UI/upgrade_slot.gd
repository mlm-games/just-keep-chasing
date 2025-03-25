class_name SlotContainer extends MarginContainer

signal slot_clicked
#FIXME: Pick based on spawn chance
@export var augment : Augments

var panel_entered : bool = false
var original_scale : Vector2
var hover_scale : Vector2 = Vector2(1.1, 1.1)
var hover_tween : Tween

@warning_ignore("narrowing_conversion")
var final_price: int

func _ready() -> void:
	augment = pick_augment_by_rarity()
	#TODO: Change the text shadow background color based on its rarity (even the ninepatchrect or panel's color?)
	original_scale = scale
	setup_slot()
	pivot_offset = size / 2

func pick_augment_by_rarity() -> Augments:
	var temp_augment : Augments = GameState.collection_res.augments.values().pick_random()
	if temp_augment.rarity.current_value < randf():
		temp_augment = pick_augment_by_rarity()
	return temp_augment

func setup_slot() -> void:
	if augment != null:
		@warning_ignore("narrowing_conversion")
		final_price = augment.augment_price * GameState.price_multiplier
		%TextureRect.texture = augment.augment_icon
		%UpgradeLabel.text = tr(augment.id.capitalize())
		%PriceContainer.text = GameState.get_currency_bbcode() + str(final_price)
		red_out_unbuyable_slots()

func red_out_unbuyable_slots() -> void:
	if final_price > GameState.research_points - GameStats.get_stat(GameStats.Stats.ITEM_LEND_THRESHOLD):
		%PriceContainer.modulate = Color(1.0, 0.333, 0.11)
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

func buy_if_rich_enough() -> void:
	if GameState.research_points + GameStats.get_stat(GameStats.Stats.ITEM_LEND_THRESHOLD) >= final_price:
		GameState.apply_augment(augment)
		# Increase the price multiplier after purchase
		GameState.price_multiplier *= (1 + GameState.price_increase_rate)
		GameState.research_points -= final_price
		
		CountStats.augment_items_collection_stats[augment] += 1
		
		queue_free()


func _input(event: InputEvent) -> void:
	if panel_entered and event.is_pressed():
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			# Click anim when unbuyable
			var click_tween : Tween = create_tween()
			click_tween.set_trans(Tween.TRANS_CUBIC)
			click_tween.set_ease(Tween.EASE_OUT).set_ignore_time_scale()
			click_tween.tween_property(self, "scale", original_scale * 0.95, 0.1)
			click_tween.tween_property(self, "scale", hover_scale, 0.1)
			
			# FIXME: Play click sound
			#Sound.play_sfx("click")
			
			slot_clicked.emit()
			panel_entered = false
