#class_name PoolManager
extends Node

var pools := {}
var pool_configs := {
	# DATA: "scene_path": {"initial_size": 20, "max_size": 100}
	"uid://b5x54mjk1mls0": {"initial": 200, "max": 10000}
}

func _ready() -> void:
	for scene_path in pool_configs:
		var config = pool_configs[scene_path]
		var scene = load(scene_path)
		register_pool(scene, config.initial, config.max)

func register_pool(scene: PackedScene, initial_size: int = 20, max_size: int = 10000) -> void:
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
