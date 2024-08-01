class_name PurchaseButton
extends Button

const MARGIN = 24.0

var _focused: = false
var _hovered: = false
var _pressed: = false
var _color_locked: = false
var _value: = 10

@onready var price_label: Label = $PriceContainer/MarginContainer2/PriceLabel
@onready var prophylactics_icon: TextureRect = $PriceContainer/MarginContainer/ProphylacticsIcon


func set_value(value: int) -> void:
	_value = value
	price_label.text = str(value)

func set_icon(icon: Texture, color: Color = Color.WHITE) -> void:
	prophylactics_icon.set_icon(icon, color)
