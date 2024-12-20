#Fixme: Gun rotating weirdly
#Fixme: Dying when paused is a softlock!
#HACK: Add upgrade screen pop up like a transition
#HACK: Use prophyliptics to make anti-bodies/ buy anti-bodies?
#hack: the final secret boss is the rogue multiplying xenobot (like how cancer cells are just rogue human cells) (could make a lore story based on this...)
#HACK: The guns are similar to items in godotneers data model vid, can make an icon also for touchscreenbutton/changeGunButton
#hack: (not imp due to diff bullet speeds) Changing bullet icons like nuclear throne will feel like bullets are doing different dmg
#hack: Collision bouncing in the direction of collision direction for specific bullets?
#heartbeast video for making the sawblades balloon game (Collision bouncing in the direction of collision direction)
#Powerups only in singleplayer
# when new difficulty is unlocked for all kinds of viruses, achievement can be like: little did he know, the stronger ones were good at hiding 
#hack:A gamemode, You can only move a certain amt in a certain amt of time, (experiment until its fun)
#HACK: The powerup has a initial velocity to the opposite direction of the player and it then accelerates toward the player upto a limit speed.
#HACK: Player's gun doesnt slow down on slow_time powerup [upgraded!]
#HACK: For collectibles, you can do the collection like how vampire survivors does it, call a state change fron idle to follow and let it get attracted at a certain speed after moving away for a second
#hack: Use inherited scenes for powerups.
#todo: Add a upgrade that makes you damage enemies on contact
#TODO: Add a WorldEnvironiment node to make the colors look good against the parallax image
#TODO: Slight zoom-in when collecting a upgrade, zoom-out after collection, (zoom in screeneffects)
#hack: if memory available (>90%), let upgrades layer stay, or else free from memory.
#Example: 
#initial_speed = -300
#attraction_velocity: Vector2
#func follow():
#	attraction_velocity = initial_speed * direction
#	attraction_velocity += direction * speed
#HACK: Give a first timer tutorial where how T works is told by a video? and Add a fast moving enemy in the end so the player dies, and for every new gun he gets, he will defeat a new wave (previously not impossible, but insane)
#TODO: An awesome way to unlock guns is by making them unlockable by having to play a mini 2 min round with them, and finish it without dying?
#Todo: Bazooka, destroys obstacles and gives health
#HACK: Use the canvascolor node to change environiment colors when new waves appear...
#HACK: A tickbox in pause menu that hides all buttons except pause button.
#TODO: Change the upgrade layer from spawning based to enemy kill based (+10 every time it appears and goes)
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
	#TODO: Replace randfs in the powertype scene itself
	var powerup: Powerup = powerups.pick_random()
	if powerup.spawn_chance < randf():
		powerup = get_random_powerup()
	return powerup

func switch_weapon() -> void:
	if guns.size() != 0:
		current_gun_index = (current_gun_index + 1) % guns.size()
		get_tree().call_group("Weapons", "queue_free")
		var gun_instance = guns[current_gun_index].instantiate()
		player.add_child(gun_instance)

func throw_weapon() -> void:
	if guns.size() != 0:
		var thrown_weapon = get_tree().get_first_node_in_group("Weapons")
		var thrown_weapon_scene = guns[current_gun_index]
		if thrown_weapon:
			guns.erase(thrown_weapon_scene)
		thrown_guns.append(thrown_weapon_scene)
		thrown_weapon.reparent(self)
		thrown_weapon.remove_from_group("Weapons")
		thrown_weapon.add_to_group("Dropped Weapons")
		switch_weapon()

func pick_up_weapon() -> void:
	#Todo: Whne near the gun, it is highlighted, so that it can be clicked.
	print(thrown_guns.size())
	if thrown_guns.size() > 0:
		var weapon = get_tree().get_first_node_in_group("Dropped Weapons")
		add_child(weapon)
		weapon.remove_from_group("Dropped Weapons")
		weapon.add_to_group("Weapons")
		get_tree().call_group("Weapons", "queue_free")
		guns.append(thrown_guns.pop_back())
	else:
		switch_weapon()


func use_powerup(powerup_type: int) -> void:
	if GameState.powerups[powerup_type] > 0:
		GameState.powerups[powerup_type] -= 1
		match powerup_type:
			GameState.PowerupType.SLOW_TIME:
				Engine.time_scale = 0.75 # Could do -= and += 0.25
				await get_tree().create_timer(2.0).timeout
				Engine.time_scale = 1.0
			GameState.PowerupType.SCREEN_BLAST:
				for enemy in get_tree().get_nodes_in_group("Enemies"):
					enemy.queue_free()
			GameState.PowerupType.HEAL:
				player.health_component.heal(20)
			GameState.PowerupType.INVINCIBLE:
				player.health_component.disable_for_secs(20)
		hud.update_hud()
