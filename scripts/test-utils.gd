class_name TestUtils extends Node



static func _add_shine_effect(node: CanvasItem):
	var shine = ColorRect.new()
	shine.set_anchors_preset(Control.PRESET_FULL_RECT)
	shine.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	var gradient = GradientTexture2D.new()
	var grad = Gradient.new()
	grad.add_point(0.0, Color(1, 1, 1, 0))
	grad.add_point(0.5, Color(1, 1, 1, 0.1))
	grad.add_point(1.0, Color(1, 1, 1, 0))
	gradient.gradient = grad
	gradient.fill_from = Vector2(0, 0)
	gradient.fill_to = Vector2(1, 1)
	
	shine.material = ShaderMaterial.new()
	shine.material.shader = preload("res://resources/shaders/button_shine.gdshader")
	shine.material.set_shader_parameter("shine_gradient", gradient)
	shine.material.set_shader_parameter("shine_speed", 1.5)
	A.add_child(shine)
	
	
#func _gui_input(event: InputEvent) -> void:
	#if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		#_create_ripple(event.position)

static func _create_ripple(node: Control, pos: Vector2) -> void:
	var ripple = ColorRect.new()
	ripple.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ripple.material = ShaderMaterial.new()
	ripple.material.shader = preload("res://resources/button_ripple.gdshader")
	ripple.size = node.size * 2.0
	ripple.position = pos - ripple.size / 2.0
	
	node.add_child(ripple)
	#ripples.append(ripple)
	
	var tween = node.create_tween()
	tween.tween_method(_update_ripple.bind(ripple), 0.0, 1.0, 0.5)
	tween.tween_callback(func():
		#ripples.erase(ripple)
		ripple.queue_free()
	)

static func _update_ripple(value: float, ripple: ColorRect) -> void:
	ripple.material.set_shader_parameter("progress", value)
