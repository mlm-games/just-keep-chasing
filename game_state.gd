extends Node

var slow_time_powerup: int = 0
var screen_blast_powerup: int = 0
var heal_powerup: int = 0

func powerup_collected(powerup_name) -> void:
	match powerup_name:
		"SlowTimePowerup":
			slow_time_powerup += 1
		"ScreenBlastPowerup":
			screen_blast_powerup += 1
		"HealPowerup":
			heal_powerup += 1

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("slow_time_powerup"):
		use_powerup("slow_time_powerup")
	elif event.is_action_pressed("screen_blast_powerup"):
		use_powerup("screen_blast_powerup")
	elif event.is_action_pressed("heal"):
		use_powerup("heal")

func use_powerup(powerup: String) -> void:
	match powerup:
		"slow_time_powerup":
			if slow_time_powerup > 0:
				Engine.time_scale = 0.5
				slow_time_powerup -= 1
				await get_tree().create_timer(2.0).timeout
				Engine.time_scale = 1.0
		"screen_blast_powerup":
			if screen_blast_powerup > 0:
				screen_blast_powerup -= 1
				for enemy in get_tree().get_nodes_in_group("Enemies"):
					enemy.queue_free()
		"heal":
			if heal_powerup > 0:
				heal_powerup -= 1
				var player = get_tree().get_first_node_in_group("Player")
				if player and player.has_node("health_component"):
					player.health_component.heal(20)
