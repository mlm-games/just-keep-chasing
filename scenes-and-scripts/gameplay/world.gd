extends Node2D

#TODO: Powerups - screen blast (using method 3 from this response- https://g.co/gemini/share/a136ae4cd130,  
#TODO: change the name to some virus related thingy
#TODO: Collision bouncing in the direction of collision direction for specific bullets?
#heartbeast video for making the sawblades balloon game (Collision bouncing in the direction of collision direction)
#Powerups only in singleplayer
#TODO: Add the description based on u being an antibody trying to fight off the rampant bacteria and viruses (has a lot of potential for different diseases, in cancer mode u fight other antibodies as a nanobot trying to stop them from killing the wrong bacteria? (i dont properly know how cancer works)
# when new difficulty is unlocked for all kinds of viruses, achievement can be like: little did he know, the stronger ones were good at hiding 

#For state change see bitlytic video on it.
#FOr collectibles, you can do the collection like how vampire survivors does it, call a state change fron idle to follow and let it get attracted at a certain speed after moving away for a second
#Example: 
#initial_speed = -300
#attraction_velocity: Vector2
#func follow():
#	attraction_velocity = initial_speed * direction
#	attraction_velocity += direction * speed

@export var powerups: Array[Powerup] = []

@onready var out_of_view_spawn_location : PathFollow2D = %OutOfViewSpawnLocation


func _on_enemy_spawn_timer_timeout() -> void:
	var enemy_scene = load("res://scenes-and-scripts/characters/enemy"+str(randi_range(1,2))+".tscn")
	var enemy_instance = enemy_scene.instantiate()
	out_of_view_spawn_location.progress_ratio = randf()
	enemy_instance.global_position = out_of_view_spawn_location.global_position
	%EnemiesNode.add_child(enemy_instance)


func _on_powerup_spawn_timer_timeout() -> void:
	var powerup = powerups.pick_random().scene
	var powerup_instance = powerup.instantiate()
	out_of_view_spawn_location.progress_ratio = randf()
	powerup_instance.global_position = out_of_view_spawn_location.global_position
	%PowerupsNode.add_child(powerup_instance)


	#Powerup 1
	if Input.is_action_just_pressed("slow_time_powerup") && GameState.slow_time_powerup_count > 0:
		Engine.time_scale = 0.5
		GameState.slow_time_powerup_count-=1
		await get_tree().create_timer(2.0).timeout
		Engine.time_scale = 1.0
	
	#Powerup 2
	if Input.is_action_just_pressed("screen_blast_powerup") && GameState.screen_blast_powerup_count > 0:
		for enemy in get_tree().get_nodes_in_group("Enemies"):
			enemy.queue_free()







