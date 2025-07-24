#class_name PoolManager
extends Node

var pools := {}

func get_pool(scene: PackedScene) -> ObjectPool:
	if not pools.has(scene):
		var pool = ObjectPool.new(scene)
		#add_child(pool) Already present in Objpool
		pools[scene] = pool
	return pools[scene]

func get_resource_pool():
	pass
