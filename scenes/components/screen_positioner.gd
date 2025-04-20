class_name ScreenPositionerControl
extends Control

var target_control: Control = null
var position_offset: Vector2

static var viewport_bounds: Vector2i:
	get: return DisplayServer.screen_get_usable_rect().size

func _ready() -> void:
		process_mode = Node.PROCESS_MODE_ALWAYS

func update_dimensions() -> void:
		global_position = Vector2.ZERO
		size = Vector2.ZERO

func set_pos(pos: Vector2, keep_offsets : bool = false) -> void:
		update_dimensions()
		pos.x = clamp(pos.x, 0, viewport_bounds.x - size.x)
		pos.y = clamp(pos.y, 0, viewport_bounds.y - size.y)
		global_position = round(pos)

func center_above_position(pos: Vector2, offset: Vector2 = Vector2.ZERO) -> void:
		update_dimensions()
		pos.x -= floor(size.x / 2)
		pos.y -= size.y
		pos += offset
		set_pos(pos)

func center_above_control(control: Control, offset: Vector2 = Vector2.ZERO) -> void:
		update_dimensions()
		var new_pos: Vector2 = control.get_global_transform_with_canvas().origin
		new_pos.x += floor((control.size.x / 2) - size.x / 2)
		new_pos.y -= size.y
		new_pos += offset
		set_pos(new_pos)

func center_below_control(control: Control, offset: Vector2 = Vector2.ZERO) -> void:
		update_dimensions()
		var new_pos: Vector2 = control.get_global_transform_with_canvas().origin
		new_pos.x += floor((control.size.x / 2) - size.x / 2)
		new_pos.y += control.size.y
		new_pos += offset
		set_pos(new_pos)

func center_below_if_space_or_above(control: Control, offset: Vector2 = Vector2.ZERO) -> void:
		update_dimensions()
		var has_space_below = control.global_position.y + control.size.y + offset.y + size.y <= viewport_bounds.y
		
		if has_space_below:
				center_below_control(control, offset)
		else:
				center_above_control(control, offset)

func center_above_if_space_or_below(control: Control, offset: Vector2 = Vector2.ZERO) -> void:
		update_dimensions()
		var has_space_above = control.global_position.y - offset.y - size.y >= 0
		
		if has_space_above:
				center_above_control(control, offset)
		else:
				center_below_control(control, offset)

func follow_control(control: Control) -> void:
		position_offset = get_global_transform_with_canvas().origin - control.get_global_transform_with_canvas().origin
		target_control = control

func stop_following() -> void:
		target_control = null

func _process(_delta: float) -> void:
		if target_control == null or not is_instance_valid(target_control):
				return
				
		if not target_control.is_inside_tree():
				stop_following()
		else:
				set_pos(target_control.get_global_transform_with_canvas().origin + position_offset)
