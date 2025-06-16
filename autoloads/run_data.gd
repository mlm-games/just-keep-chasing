# Gets reset every time a new game starts.
extends Node

signal time_updated(seconds: int)
signal research_points_updated(amount: int)

var projectile_root : Node2D
var world: World #TODO: remove these
var player: Player
var hud: HUD

var elapsed_time: int = 0:
	set(val):
		elapsed_time = val
		time_updated.emit(elapsed_time)
		#if world: world.time_based_enemy_type_changer()

var research_points: int = 0:
	set(val):
		research_points = val
		research_points_updated.emit(research_points)
		#world.hud.update_currency_label()
		#world.hud.update_progress_bar(val)
		
var powerups: Dictionary = {}
var upgrade_shop_spawn_divisor: float = 5.0

func reset():
	elapsed_time = 0
	research_points = 0
	upgrade_shop_spawn_divisor = 5.0
	projectile_root = get_tree().get_first_node_in_group("ProjectilesNode")
	world = get_tree().get_first_node_in_group("World")
	player = get_tree().get_first_node_in_group("Player")
	hud = get_tree().get_first_node_in_group("HUD")
	powerups = {
		GameState.PowerupType.SLOW_TIME: 0,
		GameState.PowerupType.SCREEN_BLAST: 0,
		GameState.PowerupType.HEAL: 0,
		GameState.PowerupType.INVINCIBLE: 0,
	}
	print("RunState has been reset.")
