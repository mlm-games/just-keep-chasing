extends RichTextLabel

func _ready() -> void:
	minimum_size_changed.connect(_on_size_changed)


func _on_size_changed() -> void:
	pivot_offset = size/2
	var magnitude: float = 27/size.x
	StaticScreenEffects.squash_simple(self, magnitude, magnitude)
