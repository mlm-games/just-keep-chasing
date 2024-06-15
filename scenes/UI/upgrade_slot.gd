class_name SlotContainer extends MarginContainer

signal slot_clicked

var panel_entered : bool = false


func _on_panel_mouse_entered() -> void:
	panel_entered = true


func _on_panel_mouse_exited() -> void:
	panel_entered = false

func _input(event: InputEvent) -> void:
	if panel_entered and event.is_pressed():
		slot_clicked.emit()
		panel_entered = false
