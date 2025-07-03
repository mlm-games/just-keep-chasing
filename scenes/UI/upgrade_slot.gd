class_name SlotContainer extends MarginContainer

signal slot_clicked

@export var augment: AugmentsData

var final_price: int
var panel_entered : bool = false
var hover_tween: Tween
var hover_scale := Vector2(1.1, 1.1)
var original_scale := scale
var bought := false:
	set(val): if val == true:
		panel.mouse_entered.disconnect(_on_panel_mouse_entered)
		panel.mouse_exited.disconnect(_on_panel_mouse_exited)

@onready var texture_rect: TextureRect = %TextureRect
@onready var upgrade_label: Label = %UpgradeLabel
@onready var price_container: RichTextLabel = %PriceContainer
@onready var panel: PanelContainer = %Panel
@onready var description_label: RichTextLabel = %DescriptionLabel
@onready var point_light_2d: PointLight2D = %PointLight2D

func _ready():
	augment = pick_augment_by_rarity()
	
	if augment:
		_setup_slot()
	else:
		# Handle case where no augment could be picked
		queue_free()
	
	panel.mouse_entered.connect(_on_panel_mouse_entered)
	panel.mouse_exited.connect(_on_panel_mouse_exited)
	
	pivot_offset = size/2
	resized.connect(func(): pivot_offset = size/2)
	
	$PopupAnimator.animate_in()
	await $PopupAnimator.animated_in
	red_out_unbuyable_slots()

func _setup_slot():
	final_price = int(augment.augment_price * RunData.price_multiplier)
	
	texture_rect.texture = augment.augment_icon
	upgrade_label.text = tr(CollectionManager.get_resource_name(augment).capitalize())
	price_container.text = GameState.get_currency_bbcode() + str(final_price)
	description_label.text = StaticUtils.get_augment_description(augment)
	
	_set_visuals_from_rarity()
	_update_buyable_state()

func _set_visuals_from_rarity():
	# Assume rarity is an int from 0 to 4
	var rarity_color = C.RARITY_COLORS.get(augment.rarity, Color.WHITE)
	
	# Apply a shader-based glow
	var mat = ShaderMaterial.new()
	mat.shader = preload("res://resources/shaders/rarity_glow.gdshader")
	mat.set_shader_parameter("glow_color", rarity_color)
	texture_rect.material = mat
	
	# You could also change the panel stylebox here based on rarity
	# panel.add_theme_stylebox_override("panel", load("res://.../rare_panel_style.tres"))
	
func _update_buyable_state():
	var can_afford = RunData.mito_energy >= final_price + CharacterStats.get_stat(CharacterStats.Stats.ITEM_LEND_THRESHOLD)
	set_process_input(can_afford) # Only allow input if it can be bought
	
	if can_afford:
		modulate = Color.WHITE
		price_container.modulate = Color.WHITE
	else:
		modulate = Color(0.6, 0.6, 0.6) # Dim the whole slot
		price_container.modulate = Color(1.0, 0.3, 0.3)

#func _gui_input(event: InputEvent):
	#if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		#buy_augment()
		#accept_event() # Consume the input

#func buy_augment():
	#if RunData.mito_energy < final_price: return
#
	#RunData.mito_energy -= final_price
	#GameState.apply_augment(augment)
	#CountStats.increment_stat(CountStats.get_stat_key(augment))
#
	## Play a satisfying purchase animation and sound
	#_play_purchase_animation()

func _play_purchase_animation():
	set_process_input(false)
	var tween = create_tween().set_parallel().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK).set_ignore_time_scale().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.3)
	tween.tween_property(self, "modulate:a", 0.0, 0.3)
	
	UiAudioM.play_ui_sound(preload("res://assets/sfx/open_002.ogg")) # Example
	
	await tween.finished
	queue_free()

func _on_mouse_entered():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_ignore_time_scale()
	tween.tween_property(self, "scale", Vector2(1.1, 1.1), 0.15)
	UiAudioM.play_hover_sound()

func _on_mouse_exited():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT).set_ignore_time_scale()
	tween.tween_property(self, "scale", Vector2.ONE, 0.15)


func pick_augment_by_rarity() -> AugmentsData:
	var all_augments = CollectionManager.all_augments.values()
	var valid_augments = all_augments.filter(func(aug): return aug.augment_price * RunData.price_multiplier < RunData.mito_energy)
	
	if valid_augments.is_empty():
		# No buyable augments
		return all_augments.pick_random() # Fallback
	
	# Now, pick from the list of augments the player can actually afford
	return valid_augments.pick_random()


func setup_slot() -> void:
	if augment != null:
		@warning_ignore("narrowing_conversion")
		final_price = augment.augment_price * RunData.price_multiplier
		%TextureRect.texture = augment.augment_icon
		%UpgradeLabel.text = tr(augment.id.capitalize())
		%PriceContainer.text = GameState.get_currency_bbcode() + str(final_price)
		red_out_unbuyable_slots()

func red_out_unbuyable_slots() -> void:
	if final_price > RunData.mito_energy - CharacterStats.get_stat(CharacterStats.Stats.ITEM_LEND_THRESHOLD):
		CommonTweens.set_tweened_value(%PriceContainer, "modulate", Color(1.0, 0.333, 0.11))
		CommonTweens.set_tweened_value(self, "modulate",Color(0.7, 0.7, 0.7)) # Dim the whole slot

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
	if RunData.mito_energy - CharacterStats.get_stat(CharacterStats.Stats.ITEM_LEND_THRESHOLD) >= final_price:
		GameState.apply_augment(augment)
		# Increase the price multiplier after purchase
		RunData.price_multiplier *= (1.25 + RunData.price_increase_rate)
		RunData.mito_energy -= final_price
		bought = true
		var tween := create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_ignore_time_scale().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
		tween.tween_property(self, "scale", Vector2.ZERO, 0.25)
		CountStats.increment_stat(CountStats.get_stat_key(augment))
		UiAudioM.play_ui_sound(preload("res://assets/sfx/open_002.ogg"))
		tween.tween_callback(queue_free)


func _input(event: InputEvent) -> void:
	if panel_entered and event.is_pressed():
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			var click_tween : Tween = create_tween()
			click_tween.set_trans(Tween.TRANS_BOUNCE)
			click_tween.set_ease(Tween.EASE_OUT).set_ignore_time_scale()
			click_tween.tween_property(self, "scale", original_scale * 0.95, 0.1)
			click_tween.tween_property(self, "scale", hover_scale, 0.1)
			
			# FIXME: Play click sound
			#Sound.play_sfx("click")
			
			slot_clicked.emit()
			panel_entered = false
