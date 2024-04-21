extends Node2D


func _unhandled_input(_event: InputEvent) -> void:
	#Powerup 1
	if Input.is_action_just_pressed("slow_time_powerup") && GameState.slow_time_powerup > 0:
		Engine.time_scale = 0.5
		GameState.slow_time_powerup-=1
		await get_tree().create_timer(2.0).timeout
		Engine.time_scale = 1.0
	
	#Powerup 2
	if Input.is_action_just_pressed("screen_blast_powerup") && GameState.screen_blast_powerup > 0:
		GameState.screen_blast_powerup-=1
		for enemy in get_tree().get_nodes_in_group("Enemies"):
			enemy.queue_free()
			#HACK:If not upgraded then the code in https://gemini.google.com/share/a136ae4cd130, with it checking for layer enemy or is in group enemies (for hiding all on screen objects by making a circle on the screen, enemies, see response 3 from the link)
	
	#Powerup 3
	if Input.is_action_just_pressed("heal") and GameState.heal_powerup > 0:
		GameState.heal_powerup-=1
		var player = get_tree().get_first_node_in_group("Player")
		player.health_component.heal(20)


