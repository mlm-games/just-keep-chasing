## A generic object pooling system to reuse nodes and reduce stutter.
##[br][br]
## Instantiate this node and configure it with a [PackedScene]. It pre-instantiates
## objects and allows you to [method get_object] and [method release_object] to
## avoid the performance cost of frequent [method Node.instantiate] and
## [method Node.queue_free] calls.[br][br]
##
## To make a pooled object aware of its lifecycle, you can implement the optional
## [code]_on_spawned_from_pool()[/code] function in the pooled object's script.
##[br][br]
## [b]Usage Example:[/b]
## [codeblock lang=gdscript]
## # In your main game script or a manager singleton
## var bullet_pool: ObjectPool
##
## func _ready():
##     var bullet_scene = preload("res://projectiles/player_bullet.tscn")
##     bullet_pool = ObjectPool.new(bullet_scene, 20, 100)
##     add_child(bullet_pool)
##
## func _on_player_shoot():
##     var bullet = bullet_pool.get_object()
##     if bullet:
##         bullet.global_position = $Player/Muzzle.global_position
##
## # In the bullet's script (e.g., player_bullet.gd)
## func _on_lifetime_ended():
##     A.tree.get_first_node_in_group("game").bullet_pool.release_object(self)
## [/codeblock]
class_name ObjectPool
extends Node

var _pool_scene: PackedScene ## The scene to use for creating new objects in the pool.
var _available: Array[Node] = [] ## A list of inactive, ready-to-use objects.
var _active: Array[Node] = [] ## A list of objects currently active in the scene.
var _max_size: int ## The maximum number of objects this pool can manage.
var _is_releasing: Dictionary = {} ## Tracks objects being released

## Initializes the object pool.
##[br]
## [param scene]: The [PackedScene] that this pool will manage.
##[br]
## [param initial_size]: The number of objects to pre-instantiate when the pool is created.
##[br]
## [param max_size]: The hard limit on the number of objects (active + available) this pool can have.
func _init(scene: PackedScene, initial_size: int = 20, max_size: int = 10000):
	_pool_scene = scene
	_max_size = max_size
	
	_initialize_pool.call_deferred(initial_size)

func _initialize_pool(initial_size: int) -> void:
	for i in initial_size:
		var obj = _pool_scene.instantiate()
		add_child(obj)
		_release_object_internal(obj)

## Retrieves an inactive object from the pool, activates it, and returns it.
##[br][br]
## If the pool is empty but not at max capacity, it will instantiate a new object.
##[br]
## Returns a recycled or new node from the pool, or [code]null[/code] if the pool is at max capacity.
func get_object() -> Node:
	var obj: Node
	
	if _available.is_empty():
		if _active.size() >= _max_size:
			push_warning("ObjectPool: Max size reached")
			return null
		obj = _pool_scene.instantiate()
		add_child(obj)
	else:
		obj = _available.pop_front()
	
	_active.append(obj)
	_is_releasing.erase(obj) # Clear any release flag
	
	# Reset the object state
	#obj.visible = true
	obj.set_process(true)
	obj.set_physics_process(true)
	
	if obj.has_method("_on_spawned_from_pool"): 
		obj._on_spawned_from_pool()
	
	return obj



## Returns an active object to the pool, deactivating it for later reuse.
##[br]
## [param obj]: The node instance that was previously retrieved with [method get_object].
func release_object(obj: Node) -> void:
	if obj == null or not is_instance_valid(obj): 
		return
	
	# Prevent double-release
	if _is_releasing.has(obj):
		return
	
	_is_releasing[obj] = true
	
	# Defer the actual release to next frame
	_deferred_release.call_deferred(obj)

func _deferred_release(obj: Node) -> void:
	if not is_instance_valid(obj):
		_is_releasing.erase(obj)
		return
		
	var index = _active.find(obj)
	if index != -1:
		_active.remove_at(index)
		_release_object_internal(obj)
	
	_is_releasing.erase(obj)

## Internal helper to deactivate an object and add it to the available list.
func _release_object_internal(obj: Node) -> void:
	# Stop all processing
	#if obj.has_method("hide"): obj.visible = false
	obj.set_process(false)
	obj.set_physics_process(false)
	
	for connection in obj.get_incoming_connections():
		connection.signal.disconnect(connection.callable)
	
	if obj.has_method("_on_released_to_pool"): 
		obj._on_released_to_pool()
	
	_available.append(obj)
