class_name HUD extends CanvasLayer

const TIMER_FORMAT = "%02d:%02d"

@onready var slow_time_button: Button = %SlowTimeButton
@onready var screen_blast_button: Button = %ScreenBlastButton
@onready var heal_button: Button = %HealButton
@onready var timer_label: Label = %TimerLabel
@onready var player = get_tree().get_first_node_in_group("Player")

var elapsed_time = 0

func _on_timer_timeout() -> void:
	elapsed_time += 1
	update_timer_label()

func update_timer_label() -> void:
	var minutes = elapsed_time / 60
	var seconds = elapsed_time % 60
	timer_label.text = TIMER_FORMAT % [minutes, seconds]

func _on_slow_time_button_pressed() -> void:
	get_parent().use_powerup(get_parent().PowerupType.SLOW_TIME)
	update_slow_time_button()

func _on_screen_blast_button_pressed() -> void:
	get_parent().use_powerup(get_parent().PowerupType.SCREEN_BLAST)
	update_screen_blast_button()

func _on_heal_button_pressed() -> void:
	get_parent().use_powerup(get_parent().PowerupType.HEAL)
	update_heal_button()

func _on_guns_button_pressed() -> void:
	pass  # Replace with function body.

func update_buttons_count() -> void:
	update_slow_time_button()
	update_screen_blast_button()
	update_heal_button()

func update_slow_time_button() -> void:
	slow_time_button.text = str(player.slow_time_powerup)

func update_screen_blast_button() -> void:
	screen_blast_button.text = str(player.screen_blast_powerup)

func update_heal_button() -> void:
	heal_button.text = str(player.heal_powerup)
