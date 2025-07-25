#class_name PoolManager
extends Node

var pools := {}
var pool_configs := {
	# DATA: "scene_path": {"initial_size": 20, "max_size": 100}
}

func _ready() -> void:
	_initialize_common_pools

func _initialize_common_pools() -> void:
	# commonly used scenes go here
	#register_pool(preload("TODO: uid for bullet.tscn"), 50, 200)
	pass

func register_pool(scene: PackedScene, initial_size: int = 20, max_size: int = 100) -> void:
	if not pools.has(scene):
		var pool = ObjectPool.new(scene, initial_size, max_size)
		add_child(pool)
		pools[scene] = pool

func get_pool(scene: PackedScene) -> ObjectPool:
	if not pools.has(scene):
		register_pool(scene)
	return pools[scene]

func release_to_pool(scene: PackedScene, obj: Node) -> void:
	var pool = get_pool(scene)
	if pool:
		pool.release_object(obj)
