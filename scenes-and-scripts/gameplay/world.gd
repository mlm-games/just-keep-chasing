extends Node2D

#TODO: Powerups - Slow time(using Engine.time_scale), screen blast (using method 3 from this response- https://g.co/gemini/share/a136ae4cd130,  
#TODO: change the name to some virus related thingy
#TODO: Collision bouncing in the direction of collision direction for specific bullets?
#heartbeast video for making the sawblades balloon game (Collision bouncing in the direction of collision direction)

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

func _on_enemy_spawn_timer_timeout() -> void:
	var enemy_scene = load("res://scenes-and-scripts/characters/enemy"+str(randi_range(1,2))+".tscn")
	var enemy = enemy_scene.instantiate()
	%EnemySpawnLocation.progress_ratio = randf()
	enemy.global_position = %EnemySpawnLocation.global_position
	%EnemiesNode.add_child(enemy)
