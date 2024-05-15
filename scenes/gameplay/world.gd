#FIXME: Bullets hitting enemies multiple times give multiple coins (at the time of death only)
#FIXME: Dropping all guns and pressing space
#FIXME: Gun rotating weirdly
#FIXME: Dropping weapons when there is no weapon in hand
#HACK: Use prophyliptics to make anti-bodies/ buy anti-bodies?
#hack: the final secret boss is the rogue multiplying xenobot (like how cancer cells are just rogue human cells) (could make a lore story based on this...)
#HACK: The guns are similar to items in godotneers data model vid, can make an icon also for touchscreenbutton/changeGunButton
#hack: (not imp due to diff bullet speeds) Changing bullet icons like nuclear throne will feel like bullets are doing different dmg
#TODO: change the name to some virus related thingy
#TODO: Collision bouncing in the direction of collision direction for specific bullets?
#heartbeast video for making the sawblades balloon game (Collision bouncing in the direction of collision direction)
#Powerups only in singleplayer
#HACK: create a class firespeedtimer which is extended so that in ready fn nothing needs to be repeated by default
#TODO: Add the description based on u being an antibody trying to fight off the rampant bacteria and viruses (has a lot of potential for different diseases, in cancer mode u fight other antibodies as a nanobot trying to stop them from killing the wrong bacteria? (i dont properly know how cancer works)
# when new difficulty is unlocked for all kinds of viruses, achievement can be like: little did he know, the stronger ones were good at hiding 
#HACK:A gamemode, You can only move a certain amt in a certain amt of time, (experiment until its fun)
#HACK: The powerup has a initial velocity to the opposite direction of the player and it then accelerates toward the player upto a limit speed.
#HACK: Player's gun doesnt slow down on slow_time powerup upgraded
#HACK: For collectibles, you can do the collection like how vampire survivors does it, call a state change fron idle to follow and let it get attracted at a certain speed after moving away for a second
#TODO: Replace all 4 gun.gd, pistol.gd, machinegun.gd stuff (or 3)
#TODO: Use inherited scenes for powerups.
#TODO: Add a powerup that makes the player invincible for a certain amount of time
#TODO: Add a upgrade that makes you damage enemies on contact
#TODO: Change change_scene to file to packed

#Example: 
#initial_speed = -300
#attraction_velocity: Vector2
#func follow():
#	attraction_velocity = initial_speed * direction
#	attraction_velocity += direction * speed

extends Node2D

const ENEMY_SCENE_PATH = "res://scenes/characters/enemy%d.tscn"

@export var guns: Array[PackedScene] = []
@export var powerups: Array[Powerup] = []

@onready var hud: HUD = %HUD
@onready var out_of_view_spawn_location: PathFollow2D = %OutOfViewSpawnLocation
@onready var player: Player = %Player
@onready var enemies_node: Node2D = %EnemiesNode
@onready var powerups_node: Node2D = %PowerupsNode
@onready var enemy_spawn_timer: Timer = %EnemySpawnTimer
@onready var powerup_spawn_timer: Timer = %PowerupSpawnTimer

var enemy_health_mult = 1 
var enemy_spawn_type_range = Vector2(1, 1)
var current_gun_index: int = 0
var thrown_guns: Array[PackedScene] = []

func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()
	if hud.elapsed_time == 120:
		enemy_spawn_type_range.y = 2
		enemy_spawn_timer.wait_time = 1.9
	elif hud.elapsed_time == 240:
		enemy_spawn_type_range.y = 3
		enemy_spawn_timer.wait_time = 1.8
	else:
		enemy_spawn_timer.wait_time = max(enemy_spawn_timer.wait_time - 0.01, 0.5)
		if enemy_spawn_timer.wait_time == 0.5:
			enemy_health_mult += 0.1

func _on_powerup_spawn_timer_timeout() -> void:
	if hud.elapsed_time > 1:
		powerup_spawn_timer.start()
	spawn_powerup()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch-weapon"):
		switch_weapon()
	elif event.is_action_pressed("throw_weapon"):
		throw_weapon()
	elif event.is_action_pressed("pick_up_weapon"):
		pick_up_weapon()
	elif event.is_action_pressed("slow_time_powerup"):
		use_powerup(GameState.PowerupType.SLOW_TIME)
	elif event.is_action_pressed("screen_blast_powerup"):
		use_powerup(GameState.PowerupType.SCREEN_BLAST)
	elif event.is_action_pressed("heal"):
		use_powerup(GameState.PowerupType.HEAL)

func spawn_enemy() -> void:
	var enemy_scene = load(ENEMY_SCENE_PATH % randi_range(enemy_spawn_type_range.x, enemy_spawn_type_range.y))
	var enemy_instance = enemy_scene.instantiate()
	enemy_instance.get_node("HealthComponent").max_health *= enemy_health_mult
	out_of_view_spawn_location.progress_ratio = randf()
	enemy_instance.global_position = out_of_view_spawn_location.global_position
	enemies_node.add_child(enemy_instance)

func spawn_powerup() -> void:
	var powerup = get_random_powerup()
	var powerup_instance = powerup.scene.instantiate()
	out_of_view_spawn_location.progress_ratio = randf()
	powerup_instance.global_position = out_of_view_spawn_location.global_position
	powerups_node.add_child(powerup_instance)

func get_random_powerup() -> Powerup:
	var powerup = powerups.pick_random()
	if powerup.name == "Screen Blast" and randf() < 0.5:
		powerup = get_random_powerup()
	elif powerup.name == "Heal" and randf() < 0.25:
		powerup = powerups[0]
	return powerup

func switch_weapon() -> void:
	current_gun_index = (current_gun_index + 1) % guns.size()
	get_tree().call_group("Weapons", "queue_free")
	var gun_instance = guns[current_gun_index].instantiate()
	player.add_child(gun_instance)

func throw_weapon() -> void:
	var thrown_weapon = get_tree().get_first_node_in_group("Weapons")
	var thrown_weapon_scene = guns[current_gun_index]
	if thrown_weapon:
		guns.erase(thrown_weapon_scene)
	thrown_guns.append(thrown_weapon_scene)
	thrown_weapon.reparent(self)
	thrown_weapon.remove_from_group("Weapons")
	thrown_weapon.add_to_group("Dropped Weapons")

func pick_up_weapon() -> void:
	if thrown_guns.size() > 0:
		var weapon = get_tree().get_first_node_in_group("Dropped Weapons")
		add_child(weapon)
		weapon.remove_from_group("Dropped Weapons")
		weapon.add_to_group("Weapons")
		get_tree().call_group("Weapons", "queue_free")

func update_hud() -> void:
	hud.update_buttons_count()

func use_powerup(powerup_type: int) -> void:
	match powerup_type:
		GameState.PowerupType.SLOW_TIME:
			if player.powerups[0] > 0:
				player.powerups[0] -= 1
				Engine.time_scale = 0.75
				await get_tree().create_timer(2.0).timeout
				Engine.time_scale = 1.0
		GameState.PowerupType.SCREEN_BLAST:
			if player.powerups[1] > 0:
				player.powerups[1] -= 1
				for enemy in get_tree().get_nodes_in_group("Enemies"):
					enemy.queue_free()
		GameState.PowerupType.HEAL:
			if player.powerups[2] > 0:
				player.powerups[2] -= 1
				player.health_component.heal(20)
	update_hud()
