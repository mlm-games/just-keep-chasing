extends Node

var slow_time_powerup: int = 0
var screen_blast_powerup: int = 0
var current_game_timer : float = 0
var heal_powerup : int = 0


var elapsed_time = 0

func _ready():
	var timer = Timer.new()
	timer.autostart = true
	timer.wait_time = 1
	timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout():
	elapsed_time += 1
	@warning_ignore("integer_division")
	var minutes = elapsed_time / 60
	var seconds = elapsed_time % 60
	$Label.text = "%02d:%02d" % [minutes, seconds]

func powerup_collected(powerup_name) -> void:
	if powerup_name == "SlowTimePowerup":
		slow_time_powerup += 1
	elif powerup_name == "ScreenBlastPowerup":
		screen_blast_powerup += 1
	elif powerup_name == "HealPowerup":
		heal_powerup += 1
