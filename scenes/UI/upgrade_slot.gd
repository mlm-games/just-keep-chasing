class_name SlotContainer extends MarginContainer

signal slot_clicked

@export var augment: AugmentsData

var final_price: int
var panel_entered: bool = false
var hover_tween: Tween
var hover_scale := Vector2(1.1, 1.1)
var original_scale := Vector2.ONE
var bought := false:
	set(val):
		if val == true:
			if panel.mouse_entered.is_connected(_on_panel_mouse_entered):
				panel.mouse_entered.disconnect(_on_panel_mouse_entered)
			if panel.mouse_exited.is_connected(_on_panel_mouse_exited):
				panel.mouse_exited.disconnect(_on_panel_mouse_exited)
		bought = val

@onready var texture_rect: TextureRect = %TextureRect
@onready var upgrade_label: Label = %UpgradeLabel
@onready var price_container: RichTextLabel = %PriceContainer
@onready var panel: PanelContainer = %Panel
@onready var description_label: RichTextLabel = %DescriptionLabel
@onready var point_light_2d: PointLight2D = %PointLight2D


func _ready() -> void:
	original_scale = scale
	
	augment = pick_augment_by_affordability()
	
	if augment:
		_setup_slot()
	else:
		queue_free()
		return
	
	panel.mouse_entered.connect(_on_panel_mouse_entered)
	panel.mouse_exited.connect(_on_panel_mouse_exited)
	
	pivot_offset = size / 2
	resized.connect(func(): pivot_offset = size / 2)
	
	if has_node("PopupAnimator"):
		$PopupAnimator.animate_in()
		await $PopupAnimator.animated_in
	
	_update_buyable_state()


func _setup_slot() -> void:
	final_price = int(augment.augment_price * RunData.price_multiplier)
	
	texture_rect.texture = augment.augment_icon
	upgrade_label.text = tr(CollectionManager.get_resource_name(augment).capitalize())
	price_container.text = GameState.get_currency_bbcode() + str(final_price)
	description_label.text = Utils.get_augment_description(augment)
	
	_set_visuals_from_rarity()


func _set_visuals_from_rarity() -> void:
	var rarity_color = C.RARITY_COLORS.get(augment.rarity, Color.WHITE)
	
	var mat = ShaderMaterial.new()
	mat.shader = preload("res://resources/shaders/rarity_glow.gdshader")
	mat.set_shader_parameter("glow_color", rarity_color)
	texture_rect.material = mat


func _update_buyable_state() -> void:
	var threshold = CharacterStats.get_stat(CharacterStats.Stats.ITEM_LEND_THRESHOLD)
	var can_afford = RunData.mito_energy >= final_price + threshold
	
	if can_afford:
		modulate = Color.WHITE
		price_container.modulate = Color.WHITE
	else:
		modulate = Color(0.6, 0.6, 0.6)
		price_container.modulate = Color(1.0, 0.3, 0.3)


func pick_augment_by_affordability() -> AugmentsData:
	var all_augments = CollectionManager.all_augments.values()
	if all_augments.is_empty():
		return null
	
	var threshold = CharacterStats.get_stat(CharacterStats.Stats.ITEM_LEND_THRESHOLD)
	var valid_augments = all_augments.filter(func(aug: AugmentsData):
		return RunData.mito_energy - threshold >= int(aug.augment_price * RunData.price_multiplier)
	)
	
	if valid_augments.is_empty():
		return all_augments.pick_random()
	
	return valid_augments.pick_random()


func red_out_unbuyable_slots() -> void:
	_update_buyable_state()


func _on_panel_mouse_entered() -> void:
	if bought:
		return
	
	panel_entered = true
	
	if hover_tween and hover_tween.is_valid():
		hover_tween.kill()
	
	hover_tween = create_tween().set_ignore_time_scale().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	hover_tween.tween_property(self, "scale", hover_scale, 0.1)
	
	UiAudioManager.play_hover_sound()


func _on_panel_mouse_exited() -> void:
	if bought:
		return
	
	panel_entered = false
	
	if hover_tween and hover_tween.is_valid():
		hover_tween.kill()
	
	hover_tween = create_tween().set_ignore_time_scale().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	hover_tween.tween_property(self, "scale", original_scale, 0.1)


func buy_if_rich_enough() -> void:
	var threshold = CharacterStats.get_stat(CharacterStats.Stats.ITEM_LEND_THRESHOLD)
	
	if RunData.mito_energy - threshold >= final_price:
		GameState.apply_augment(augment)
		RunData.price_multiplier *= (1.25 + RunData.price_increase_rate)
		RunData.mito_energy -= final_price
		bought = true
		
		CountStats.increment_stat(CountStats.get_stat_key(augment))
		UiAudioManager.play_ui_sound(preload("res://assets/sfx/open_002.ogg"))
		
		_play_purchase_animation()


func _play_purchase_animation() -> void:
	var tween := create_tween()
	tween.set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.set_ignore_time_scale().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(self, "scale", Vector2.ZERO, 0.25)
	tween.tween_callback(queue_free)


func _input(event: InputEvent) -> void:
	if bought:
		return
	
	if panel_entered and event.is_pressed():
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			var click_tween: Tween = create_tween()
			click_tween.set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
			click_tween.set_ignore_time_scale().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
			click_tween.tween_property(self, "scale", original_scale * 0.95, 0.1)
			click_tween.tween_property(self, "scale", hover_scale, 0.1)
			
			UiAudioManager.play_click_sound()
			
			slot_clicked.emit()
			panel_entered = false
