class_name MachineGun extends BaseGun

func _on_fire_rate_timer_timeout() -> void:
	if not _enemies_in_range.is_empty():
		animation_player.play("fire")
		spawn_bullet()
		if ammo <= 0:
			reload()
