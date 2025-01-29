class_name PickUp
extends Area2D

signal picked_up(pickup_type: GameState)

var world_rid: RID

@onready var my_rid: RID = get_canvas_item()
var shape_rid: RID

const CURRENCY_ICONS: Dictionary = {
	"currency": preload("res://assets/sprites/currency.png"),
}

# Key: Physics RID, Value: Corresponding Rendering RID
var physics_rids: Dictionary = {}
# Key: Rendering RID, Value: ResourceType
var render_rids: Dictionary = {}

# Key: All RIDs moving to player; Value: t value (float [0-1])
var moving_to_player: Dictionary = {}

# Key: RID (RenderingServer); Value: position (Vector2)
var positions: Dictionary = {}

var collected_by: Player

func _ready() -> void:
	shape_rid = PhysicsServer2D.circle_shape_create()
	PhysicsServer2D.shape_set_data(shape_rid, 3.0)
	await get_tree().create_timer(0.5).timeout
	collected_by = get_node("/root/World/Player")
	world_rid = get_world_2d().get_rid()

func create_drop(pos: Vector2, resource_type: int) -> void:
	var drop = PhysicsServer2D.area_create()
	PhysicsServer2D.area_add_shape(drop, shape_rid)
	PhysicsServer2D.area_set_space(drop, world_rid)
	
	PhysicsServer2D.area_set_monitorable(drop, false)
	PhysicsServer2D.area_set_collision_layer(drop, 4)
	PhysicsServer2D.area_set_collision_mask(drop, 0)
	PhysicsServer2D.area_set_transform(drop, Transform2D(0, pos))
	
	var sprite = RenderingServer.canvas_item_create()
	var texture: Texture2D = CURRENCY_ICONS["currency"]
	RenderingServer.canvas_item_add_texture_rect(sprite, Rect2(Vector2.ZERO, texture.get_size()), texture, false, Color.WHITE)
	RenderingServer.canvas_item_set_parent(sprite, my_rid)
	_set_sprite_pos(pos, sprite)
	
	physics_rids[drop] = sprite
	render_rids[sprite] = resource_type


func _set_sprite_pos(pos: Vector2, sprite: RID, update_positions: bool = true) -> void:
	RenderingServer.canvas_item_set_transform(sprite, Transform2D(0, pos))
	if update_positions:
		positions[sprite] = pos

func pickup(physics_rid: RID) -> void:
	if physics_rids.has(physics_rid):
		var render_rid: RID = physics_rids[physics_rid]
		
		var sprite_pos: Vector2 = positions[render_rid]
		var move_away_dir: Vector2 = collected_by.global_position.direction_to(sprite_pos)
		var move_away_dest: Vector2 = sprite_pos + move_away_dir*26
		create_tween().tween_method(_set_sprite_pos.bind(render_rid), sprite_pos, move_away_dest,
				0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD) \
				.finished.connect(_on_move_away_finished.bind(render_rid))
		#SFX.play(Sound.PICKUP_START)
		
		destroy(physics_rid)
		var resource_type: int = render_rids[render_rid]
		picked_up.emit(resource_type)

func _on_move_away_finished(rid: RID) -> void:
	moving_to_player[rid] = 0.0

func _process(delta: float) -> void:
	for rid: RID in moving_to_player.keys():
		moving_to_player[rid] += delta * 6
		var t: float = moving_to_player[rid]
		var new_pos: Vector2 = lerp(positions[rid], collected_by.global_position, ease(t, 1.5))
		_set_sprite_pos(new_pos, rid, false)
		if t >= 1.0:
			#SFX.play(Sound.PICKUP_RESOURCE, 0.1)
			destroy(rid)

func destroy(rid: RID) -> void:
	if physics_rids.has(rid):
		PhysicsServer2D.free_rid(rid)
		physics_rids.erase(rid)
	elif render_rids.has(rid):
		RenderingServer.free_rid(rid)
		render_rids.erase(rid)
		moving_to_player.erase(rid)
		positions.erase(rid)

func _exit_tree() -> void:
	for rid: RID in physics_rids:
		PhysicsServer2D.free_rid(rid)
	for rid: RID in render_rids:
		RenderingServer.free_rid(rid)
