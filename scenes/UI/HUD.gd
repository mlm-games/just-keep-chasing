#hack: Display ammo_count and reload status?
#hack: touch_button_changing_icons...

class_name HUD extends CanvasLayer

const TIMER_FORMAT = "%02d:%02d"
var pop_up_on_screen = false

@onready var slow_time_button: Button = %SlowTimeButton
@onready var screen_blast_button: Button = %ScreenBlastButton
@onready var heal_button: Button = %HealButton
@onready var timer_label: Label = %TimerLabel
@onready var player : Player = get_tree().get_first_node_in_group("Player")

var elapsed_time = 0

func _on_timer_timeout() -> void:
	elapsed_time += 1
	update_timer_label()
	check_time_condition()
	pop_up_on_screen = false

func update_timer_label() -> void:
	@warning_ignore("integer_division")
	var minutes = elapsed_time / 60
	var seconds = elapsed_time % 60
	timer_label.text = TIMER_FORMAT % [minutes, seconds]

func _on_slow_time_button_pressed() -> void:
	get_parent().use_powerup(0)
	update_slow_time_button()

func _on_screen_blast_button_pressed() -> void:
	get_parent().use_powerup(1)
	update_screen_blast_button()

func _on_heal_button_pressed() -> void:
	get_parent().use_powerup(2)
	update_heal_button()

func _on_guns_button_pressed() -> void:
	pass  # Replace with function body.

func update_buttons_count() -> void:
	update_slow_time_button()
	update_screen_blast_button()
	update_heal_button()
#Fix enums
func update_slow_time_button() -> void:
	slow_time_button.text = str(player.powerups[0])

func update_screen_blast_button() -> void:
	screen_blast_button.text = str(player.powerups[1])

func update_heal_button() -> void:
	heal_button.text = str(player.powerups[2])

func check_time_condition() -> void:
	##Temp Upgrade condition
	if elapsed_time == 120:
		var upgrades_scene = load("res://scenes/UI/upgrades_layer.tscn").instantiate()
		#hack: Add it like a pop up like a 0.01 sec anim?
		add_child(upgrades_scene)
			
	
	##Win condition
	if elapsed_time == 300:
		if !pop_up_on_screen:
			pop_up_on_screen = true
			ScreenEffects.transition("circleIn")
			await ScreenEffects.transition_player.animation_finished
			var win_scene = load("res://scenes/UI/win_screen.tscn").instantiate()
			add_child(win_scene)
			ScreenEffects.transition("circleOut")
