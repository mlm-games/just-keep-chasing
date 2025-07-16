# Gets reset every time a new game starts.
extends Node

signal time_updated(seconds: int)
signal mito_energy_updated(amount: int)
signal in_shop_changed(is_in_shop: bool)

var is_in_shop : bool = false:
	set(val):
		is_in_shop = val
		in_shop_changed.emit(is_in_shop)


var projectile_root : Node2D
var world: World #TODO: remove these
var player: Player
var hud: HUD

var spawnable_enemies: Dictionary[int, EnemyData] = {} #key: spawn_range, value: Enemydata
var enemy_spawn_type_range := Vector2i(1, 1)


var elapsed_time: int = 0:
	set(val):
		elapsed_time = val
		time_updated.emit(elapsed_time)

var mito_energy: int = 0:
	set(val):
		mito_energy = val
		mito_energy_updated.emit(mito_energy)

var price_multiplier: float = 0.3
var price_increase_rate: float = 0.07

var powerups: Dictionary[StringName, int] = {}
var upgrade_shop_spawn_divisor: float = 5.0

func reset():
	elapsed_time = 0
	mito_energy = 0
	upgrade_shop_spawn_divisor = 5.0
	price_multiplier = 0.3
	price_increase_rate = 0.07
	spawnable_enemies = {}
	enemy_spawn_type_range = Vector2i(1, 1)
	projectile_root = A.tree.get_first_node_in_group("ProjectilesNode")
	world = A.tree.get_first_node_in_group("World")
	player = A.tree.get_first_node_in_group("Player")
	hud = A.tree.get_first_node_in_group("HUD")
	for key:StringName in CollectionManager.all_powerups:
		powerups[key] = 0
	print("RunState has been reset.")



func powerup_collected(powerup_type: StringName) -> void:
	powerups[powerup_type] += 1
	#world.hud.update_hud_buttons()
