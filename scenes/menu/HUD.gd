extends CanvasLayer

var elapsed_time = 0

func _on_timer_timeout():
	elapsed_time += 1
	@warning_ignore("integer_division")
	var minutes = elapsed_time / 60
	var seconds = elapsed_time % 60
	%TimerLabel.text = "%02d:%02d" % [minutes, seconds]

func _on_slow_time_button_pressed() -> void:
	GameState.use_powerup("slow_time_powerup")
	%SlowTimeButton.text = str(GameState.slow_time_powerup)

func _on_screen_blast_button_pressed() -> void:
	GameState.use_powerup("screen_blast_powerup")
	%ScreenBlastButton.text = str(GameState.screen_blast_powerup)

func _on_heal_button_pressed() -> void:
	GameState.use_powerup("heal")
	%ScreenBlastButton.text = str(GameState.heal_powerup)
	

func _on_guns_button_pressed() -> void:
	pass # Replace with function body.
	#%GunsButton.texture_normal = gun

