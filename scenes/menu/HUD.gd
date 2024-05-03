class_name HUD extends CanvasLayer

var elapsed_time = 0
@onready var slow_time_button: Button = %SlowTimeButton
@onready var screen_blast_button: Button = %ScreenBlastButton
@onready var heal_button: Button = %HealButton
@onready var player = get_tree().get_first_node_in_group("Player")


func _on_timer_timeout():
	elapsed_time += 1
	@warning_ignore("integer_division")
	var minutes = elapsed_time / 60
	var seconds = elapsed_time % 60
	%TimerLabel.text = "%02d:%02d" % [minutes, seconds]

func _on_slow_time_button_pressed() -> void:
	get_parent().use_powerup("slow_time_powerup")
	slow_time_button.text = str(player.slow_time_powerup)

func _on_screen_blast_button_pressed() -> void:
	get_parent().use_powerup("screen_blast_powerup")
	screen_blast_button.text = str(player.screen_blast_powerup)

func _on_heal_button_pressed() -> void:
	get_parent().use_powerup("heal")
	heal_button.text = str(player.heal_powerup)
	

func _on_guns_button_pressed() -> void:
	pass # Replace with function body.
	#%GunsButton.texture_normal = gun

func update_buttons_count():
	slow_time_button.text = str(player.slow_time_powerup)
	screen_blast_button.text = str(player.screen_blast_powerup)
	heal_button.text = str(player.heal_powerup)
