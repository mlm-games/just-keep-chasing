class_name PickUp
extends Area2D

signal picked_up

var collected_by: Player

func pickup() -> void:
	picked_up.emit()
	queue_free()
