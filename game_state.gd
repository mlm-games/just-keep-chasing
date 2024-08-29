extends Node

var highest_game_time: float = 0.0

enum PowerupType {
	SLOW_TIME,
	SCREEN_BLAST,
	HEAL,
	INVINCIBLE,
}

var powerups = {
	PowerupType.SLOW_TIME: 0,
	PowerupType.SCREEN_BLAST: 0,
	PowerupType.HEAL: 0,
	PowerupType.INVINCIBLE: 0,
}



# Player-related properties
var player_lives: int = 1

# Game-related properties
var research_points : int = 0
var current_level: int = 1
var is_game_paused: bool = false
var is_game_over: bool = false

# Inventory and items
var inventory: Dictionary = {}
var collected_items: Array = []

# Checkpoint and respawn
var last_checkpoint: Vector2 = Vector2.ZERO
var respawn_position: Vector2 = Vector2.ZERO

# Settings
var music_volume: float = 1.0
var sound_volume: float = 1.0
var is_fullscreen: bool = false


func powerup_collected(powerup_type: int) -> void:
	powerups[powerup_type] += 1
	#update_hud()


# Methods for managing game state
func reset_game() -> void:
	research_points = 0
	current_level = 1
	is_game_paused = false
	is_game_over = false
	inventory.clear()
	collected_items.clear()
	last_checkpoint = Vector2.ZERO
	respawn_position = Vector2.ZERO
	# Reinitialize the player?

func save_game() -> void:
		# Implement saving game state to a file or database
	pass

func load_game() -> void:
		# Implement loading game state from a file or database
	pass

func update_highest_game_time(time: float) -> void:
	if time > highest_game_time:
		highest_game_time = time

func add_to_inventory(item: String, quantity: int = 1) -> void:
	if inventory.has(item):
		inventory[item] += quantity
	else:
		inventory[item] = quantity

func remove_from_inventory(item: String, quantity: int = 1) -> void:
	if inventory.has(item):
		inventory[item] -= quantity
		if inventory[item] <= 0:
			inventory.erase(item)

func collect_item(item: String) -> void:
	if not collected_items.has(item):
		collected_items.append(item)

func has_collected_item(item: String) -> bool:
	return collected_items.has(item)

func set_checkpoint(position: Vector2) -> void:
	last_checkpoint = position

func respawn_player() -> void:
		# Implement respawning the player at the last checkpoint or respawn position
	pass
