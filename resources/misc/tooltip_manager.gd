#class_name TooltipManager
extends Node

## Main singleton that handles tooltip requests
## Access via TooltipManager.get_instance().show_tooltip(content, target)

signal tooltip_shown(content: TooltipContent, target: Control)
signal tooltip_hidden()

var _current_tooltip: TooltipDisplay = null

func _ready() -> void:
	# Create tooltip display when manager is ready
	_current_tooltip = preload("uid://dyemx8h22argg").instantiate()
	self.add_child(_current_tooltip)
	_current_tooltip.hide()

func show_tooltip(content: TooltipContent, target: Control) -> void:
	if not is_instance_valid(_current_tooltip):
		return
		
	_current_tooltip.set_content(content)
	_current_tooltip.position_relative_to(target)
	_current_tooltip.show_with_animation()
	tooltip_shown.emit(content, target)

func hide_tooltip() -> void:
	if is_instance_valid(_current_tooltip):
		_current_tooltip.hide_with_animation()
		tooltip_hidden.emit()
