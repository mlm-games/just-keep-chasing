## The actual visual tooltip that appears on screen
class_name TooltipDisplay
extends ScreenPositionerControl

@onready var label: RichTextLabel = %TooltipLabel
@onready var icon_texture: TextureRect = %IconTexture
@onready var panel: PanelContainer = %Panel

const MAX_WIDTH: float = 300.0
const MARGIN: float = 10.0

func _ready() -> void:
		super._ready()
		# Set layer to ensure tooltip is on top
		top_level = true
		
		# for animations
		pivot_offset = size / 2

func set_content(content: TooltipContent) -> void:
		label.text = content.text
		
		if content.icon:
				icon_texture.texture = content.icon
				icon_texture.show()
		else:
				icon_texture.hide()
		
		if content.style_override:
				panel.add_theme_stylebox_override("panel", content.style_override)
		
		label.custom_minimum_size.x = 0
		label.autowrap_mode = TextServer.AUTOWRAP_OFF
		
		await get_tree().process_frame
		
		if size.x > MAX_WIDTH:
				label.custom_minimum_size.x = MAX_WIDTH
				label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
				
				await get_tree().process_frame

func position_relative_to(target: Control) -> void:
		await get_tree().process_frame
		center_above_if_space_or_below(target, Vector2(0, MARGIN))

func show_with_animation() -> void:
		show()
		scale = Vector2.ZERO
		rotation_degrees = -5
		
		var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC).parallel()
		tween.tween_property(self, "scale", Vector2.ONE, 0.3)
		tween.tween_property(self, "rotation_degrees", 0, 0.3)

func hide_with_animation() -> void:
		var tween = create_tween()
		tween.set_ease(Tween.EASE_IN)
		tween.set_trans(Tween.TRANS_BACK)
		tween.tween_property(self, "scale", Vector2.ZERO, 0.2)
		tween.tween_callback(hide)
