extends Node


# Reparent a node under a new parent.
# Optionally updates the transform to mantain the current
# position, scale and rotation values.
func reparent_node(node: Node2D, new_parent, update_transform = false):
	var previous_xform = node.global_transform
	node.get_parent().remove_child(node)
	new_parent.add_child(node)
	if update_transform:
		node.global_transform = previous_xform

func screen_shake(duration: float, amplitude: float, camera: Camera2D):
	var tween = create_tween()
	var original_position = camera.position
	for i in range(int(duration * 60)):  # Assuming 60 FPS
		var offset = Vector2(randf() * amplitude * 2 - amplitude, 0)
		tween.tween_property(camera, "position", original_position + offset, 1.0 / 60)  # Tween for 1 frame
	tween.tween_property(camera, "position", original_position, 1.0 / 60)  # Return to original position
