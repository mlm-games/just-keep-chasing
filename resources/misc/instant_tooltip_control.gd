class_name VectorTooltipControl
extends Control

var attached_to: Control = null
var attach_offset: Vector2

# Modern HD resolution
const SCREEN_SIZE: Vector2i = Vector2i(1920, 1080)
const PADDING: float = 16.0

# Smooth animation
var target_pos: Vector2
var current_pos: Vector2
const SMOOTHING: float = 0.2

# Modern color scheme
const COLORS = {
		"background": Color(0.12, 0.14, 0.18, 0.95), # Dark blue-grey
		"border": Color(0.8, 0.8, 0.8, 0.1),
		"text": Color(0.9, 0.9, 0.9),
		"highlight": Color(0.2, 0.6, 1.0),
		"positive": Color(0.2, 0.8, 0.4),
		"negative": Color(0.8, 0.2, 0.3),
		"warning": Color(1.0, 0.7, 0.2)
}

func _ready() -> void:
		process_mode = Node.PROCESS_MODE_ALWAYS
		#add_theme_stylebox_override("panel", create_tooltip_style())
		
		# Add drop shadow
		#var shadow = RectangleShape2D.new()
		#shadow.size = Vector2(4, 4)
		#shadow.color = Color(0, 0, 0, 0.2)
		#shadow.offset = Vector2(2, 2)

#func create_tooltip_style() -> StyleBoxFlat:
		#var style = StyleBoxFlat.new()
		#style.bg_color = COLORS.background
		#style.border_color = COLORS.border
		#style.border_width_left = 2
		#style.border_width_right = 2
		#style.border_width_top = 2
		#style.border_width_bottom = 2
		#style.corner_radius_top_left = 8
		#style.corner_radius_top_right = 8
		#style.corner_radius_bottom_left = 8
		#style.corner_radius_bottom_right = 8
		#style.shadow_color = Color(0, 0, 0, 0.3)
		#style.shadow_size = 4
		#style.content_margin_left = 16
		#style.content_margin_right = 16
		#style.content_margin_top = 12
		#style.content_margin_bottom = 12
		#return style

# Show stat info with smooth bars
func show_stat_info(title: String, stats: Dictionary, max_value: float = 100.0) -> void:
		var text = "[center][b]%s[/b][/center]\n\n" % title
		
		for stat_name in stats:
				var value = stats[stat_name]
				var percentage = (value / max_value) * 100
				var bar = create_stat_bar(percentage)
				text += "[center]%s: %s %d[/center]\n" % [stat_name, bar, value]
		
		if has_node("TooltipText"):
				get_node("TooltipText").text = text

# Create visual stat bar
func create_stat_bar(percentage: float) -> String:
		var bar_length = 10
		var filled = int((percentage / 100.0) * bar_length)
		var empty = bar_length - filled
		
		var color = COLORS.positive if percentage > 66 \
				else COLORS.warning if percentage > 33 \
				else COLORS.negative
		
		return "[color=%s]%s[/color]%s" % [
				color.to_html(),
				"■".repeat(filled),
				"□".repeat(empty)
		]

# Show ability info with cooldown
func show_ability_info(ability: Dictionary) -> void:
		var text = "[center][color=%s][b]%s[/b][/color][/center]\n" % [
				COLORS.highlight.to_html(),
				ability.name
		]
		
		text += "\n%s\n" % ability.description
		
		if ability.has("cooldown"):
				var cooldown_text = "[color=%s]Cooldown: %ds[/color]" % [COLORS.negative.to_html(), ability.cooldown] if ability.cooldown > 0 else "[color=%s]Ready![/color]" % COLORS.positive.to_html()
				text += "\n%s" % cooldown_text
		
		if ability.has("cost"):
				text += "\nCost: %d" % ability.cost
		
		if has_node("TooltipText"):
				get_node("TooltipText").text = text

# Show progress info
func show_progress_info(current: float, max_value: float, label: String = "") -> void:
		var percentage = (current / max_value) * 100
		var bar = create_progress_bar(percentage)
		
		var text = ""
		if label:
				text += "[b]%s[/b]\n" % label
		text += bar
		text += "\n%.1f%%" % percentage
		
		if has_node("TooltipText"):
				get_node("TooltipText").text = text

func create_progress_bar(percentage: float) -> String:
		var bar_length = 20
		var filled = int((percentage / 100.0) * bar_length)
		var empty = bar_length - filled
		
		return "[color=%s]%s[/color][color=%s]%s[/color]" % [
				COLORS.highlight.to_html(),
				"━".repeat(filled),
				COLORS.border.to_html(),
				"━".repeat(empty)
		]

func force_size_update() -> void:
		global_position = Vector2.ZERO
		size = Vector2.ZERO

func set_pos(pos: Vector2) -> void:
		force_size_update()
		target_pos = Vector2(
				clamp(pos.x, PADDING, SCREEN_SIZE.x - size.x - PADDING),
				clamp(pos.y, PADDING, SCREEN_SIZE.y - size.y - PADDING)
		)

func _process(delta: float) -> void:
		if attached_to != null and is_instance_valid(attached_to):
				if not attached_to.is_inside_tree():
						detach()
				else:
						set_pos(attached_to.get_global_transform_with_canvas().origin + attach_offset)
		
		# Smooth position updating
		current_pos = current_pos.lerp(target_pos, SMOOTHING)
		global_position = round(current_pos)

func attach(control: Control) -> void:
		attach_offset = get_global_transform_with_canvas().origin - \
						control.get_global_transform_with_canvas().origin
		attached_to = control

func detach() -> void:
		attached_to = null
