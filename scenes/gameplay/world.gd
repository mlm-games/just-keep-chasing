extends Node2D

@export var guns: Array[PackedScene] = []

var gun_no: int = 0
var upgraded: bool = true

  
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
	var enemy_scene = load("res://scenes/characters/enemy"+str(randi_range(1,2))+".tscn")
	var enemy_instance = enemy_scene.instantiate()
	out_of_view_spawn_location.progress_ratio = randf()
	enemy_instance.global_position = out_of_view_spawn_location.global_position
	%EnemiesNode.add_child(enemy_instance)
	%EnemySpawnTimer.wait_time -= 0.005


func _on_powerup_spawn_timer_timeout() -> void:
	var powerup = powerups.pick_random().scene
	var powerup_instance = powerup.instantiate()
	out_of_view_spawn_location.progress_ratio = randf()
	powerup_instance.global_position = out_of_view_spawn_location.global_position
	%PowerupsNode.add_child(powerup_instance)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch-weapon"):
		#Scrolling through weapons
		gun_no = (gun_no + 1) % guns.size()
		get_tree().call_group("Weapons","queue_free")
		var gun_instance = guns[gun_no].instantiate()
		%Player.add_child(gun_instance)


#Make guns go off 
	if event.is_action_pressed("throw_weapon"):
		var weapon = get_tree().get_first_node_in_group("Weapons")
		weapon.reparent(get_tree().root)
		#weapon.remove_from_group("Weapons")
		#weapon.add_to_group("Dropped Weapons")

	if event.is_action_pressed("pick_up_weapon"):
		pass
		#var weapon = get_tree().get_first_node_in_group("Dropped Weapon")
		#self.add_child(weapon)
		#weapon.remove_from_group("Weapons")




