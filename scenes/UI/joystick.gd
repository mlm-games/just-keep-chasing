class_name VirtualJoystick
extends Control

signal direction_changed(dir: Vector2)
signal released

@onready var outer_ring : TextureRect = %Outer
@onready var inner_stick: TextureRect = %Inner

@export var boundary := 75.0

var _touch_index := -1
var _start_position := Vector2.ZERO
var _ring_half := Vector2.ZERO
var _inner_ring_half := Vector2.ZERO

func _ready():
	outer_ring.hide()
	inner_stick.hide()
	_ring_half = outer_ring.size * outer_ring.scale * 0.5
	_inner_ring_half = (inner_stick.size * inner_stick.scale) / 2

func _gui_input(event):
	if event is InputEventScreenTouch:
		if event.is_pressed() and _touch_index == -1:
			_start_position = event.position
			outer_ring.global_position = _start_position - _ring_half
			inner_stick.global_position = _start_position - _inner_ring_half
			outer_ring.show()
			inner_stick.show()
			_touch_index = event.index
			_update_stick_position(event.position)

		elif event.is_released() and event.index == _touch_index:
			_reset()

	elif event is InputEventScreenDrag and event.index == _touch_index:
		_update_stick_position(event.position)

func _update_stick_position(pos: Vector2):
	var vec = pos - _start_position
	var dist = vec.length()
	var dir = Vector2.ZERO if dist == 0.0 else vec / dist

	var offset = dir * min(dist, boundary)
	inner_stick.global_position = outer_ring.global_position + _ring_half + offset - _inner_ring_half
	emit_signal("direction_changed", dir)

func _reset():
	_touch_index = -1
	inner_stick.global_position = Vector2.ZERO
	outer_ring.hide()
	inner_stick.hide()
	emit_signal("released")
	emit_signal("direction_changed", Vector2.ZERO)
