class_name BaseCharacter extends CharacterBody2D

var knockback: Vector2 = Vector2.ZERO
var knockback_timer: float = 0.0

func apply_knockback(direction: Vector2, force: float, knockback_duration: float) -> void:
	knockback = direction * force
	knockback_timer = knockback_duration
