extends Button

var button : Button = Button.new()
var ripples: Array[ColorRect] = []

@export var normal_style : StyleBoxFlat
@export var hover_style : StyleBoxFlat
@export var pressed_style : StyleBoxFlat
@export var disabled_style : StyleBoxFlat

func _ready() -> void:
	normal_style = StyleBoxFlat.new()
	normal_style.bg_color = Color("#2a2a2e")
	normal_style.border_color = Color("#4a4a4f")
	normal_style.border_width_left = 2
	normal_style.border_width_top = 2
	normal_style.border_width_right = 2
	normal_style.border_width_bottom = 2
	normal_style.corner_radius_top_left = 8
	normal_style.corner_radius_top_right = 8
	normal_style.corner_radius_bottom_right = 8
	normal_style.corner_radius_bottom_left = 8
	normal_style.shadow_color = Color("#00000066")
	normal_style.shadow_size = 4
	normal_style.shadow_offset = Vector2(0, 2)
	
	
	
	# Add glow...
	normal_style.border_blend = true
	normal_style.anti_aliasing = true
	normal_style.anti_aliasing_size = 0.8

	# Button Hover State
	hover_style = StyleBoxFlat.new()
	hover_style.bg_color = Color("#3a3a3f")
	hover_style.border_color = Color("#5a5a5f")
	hover_style.border_width_left = 2
	hover_style.border_width_top = 2
	hover_style.border_width_right = 2
	hover_style.border_width_bottom = 2
	hover_style.corner_radius_top_left = 8
	hover_style.corner_radius_top_right = 8
	hover_style.corner_radius_bottom_right = 8
	hover_style.corner_radius_bottom_left = 8
	hover_style.shadow_color = Color("#00000088")
	hover_style.shadow_size = 6
	hover_style.shadow_offset = Vector2(0, 3)

	# Button Pressed State
	pressed_style = StyleBoxFlat.new()
	pressed_style.bg_color = Color("#1a1a1e")
	pressed_style.border_color = Color("#3a3a3f")
	pressed_style.border_width_left = 2
	pressed_style.border_width_top = 2
	pressed_style.border_width_right = 2
	pressed_style.border_width_bottom = 2
	pressed_style.corner_radius_top_left = 8
	pressed_style.corner_radius_top_right = 8
	pressed_style.corner_radius_bottom_right = 8
	pressed_style.corner_radius_bottom_left = 8
	pressed_style.shadow_color = Color("#00000044")
	pressed_style.shadow_size = 2
	pressed_style.shadow_offset = Vector2(0, 1)

	# Button Disabled State
	disabled_style = StyleBoxFlat.new()
	disabled_style.bg_color = Color("#1a1a1e99")
	disabled_style.border_color = Color("#3a3a3f66")
	disabled_style.border_width_left = 2
	disabled_style.border_width_top = 2
	disabled_style.border_width_right = 2
	disabled_style.border_width_bottom = 2
	disabled_style.corner_radius_top_left = 8
	disabled_style.corner_radius_top_right = 8
	disabled_style.corner_radius_bottom_right = 8
	disabled_style.corner_radius_bottom_left = 8
	
	# Font settings
	theme.set_font_size("font_size", "Button", 20)
	#theme.set_font("font", "Button", load("res://path_to_your_font.ttf"))

	# Colors
	theme.set_color("font_color", "Button", Color("#ffffff"))
	theme.set_color("font_pressed_color", "Button", Color("#ffffffee"))
	theme.set_color("font_hover_color", "Button", Color("#ffffff"))
	theme.set_color("font_disabled_color", "Button", Color("#ffffff66"))

	# Content margins
	theme.set_constant("h_separation", "Button", 16)
	
	#ResourceSaver.save(normal_style,"res://style1.tres")
	#ResourceSaver.save(hover_style,"res://style2.tres")
	#ResourceSaver.save(pressed_style,"res://style3.tres")
	#ResourceSaver.save(disabled_style,"res://style4.tres")
	#ResourceSaver.save(theme, "res://theme-button.tres")


func _add_shine_effect():
	var shine = ColorRect.new()
	shine.set_anchors_preset(Control.PRESET_FULL_RECT)
	shine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var gradient = GradientTexture2D.new()
	var grad = Gradient.new()
	grad.add_point(0.0, Color(1, 1, 1, 0))
	grad.add_point(0.5, Color(1, 1, 1, 0.1))
	# Continuing from previous shine effect...
	grad.add_point(1.0, Color(1, 1, 1, 0))
	gradient.gradient = grad
	gradient.fill_from = Vector2(0, 0)
	gradient.fill_to = Vector2(1, 1)
	
	shine.material = ShaderMaterial.new()
	shine.material.shader = preload("res://resources/misc/button_shine.gdshader")
	shine.material.set_shader_parameter("shine_gradient", gradient)
	shine.material.set_shader_parameter("shine_speed", 1.5)
	add_child(shine)
	
	
func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_create_ripple(event.position)

func _create_ripple(pos: Vector2) -> void:
	var ripple = ColorRect.new()
	ripple.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ripple.material = ShaderMaterial.new()
	ripple.material.shader = preload("res://resources/misc/button_ripple.gdshader")
	ripple.size = size * 2.0
	ripple.position = pos - ripple.size / 2.0
	
	add_child(ripple)
	ripples.append(ripple)
	
	var tween = create_tween()
	tween.tween_method(_update_ripple.bind(ripple), 0.0, 1.0, 0.5)
	tween.tween_callback(func():
		ripples.erase(ripple)
		ripple.queue_free()
	)

func _update_ripple(value: float, ripple: ColorRect) -> void:
	ripple.material.set_shader_parameter("progress", value)
