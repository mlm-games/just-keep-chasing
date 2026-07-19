## Manages a character's animations by listening to other components.
class_name AnimationComponent extends Node

@export var anims_prefix: String = "reusable_anims/"

# Assign these nodes from the character scene that owns this component.
@export var anim_player: AnimationPlayer
@export var sprite: Sprite2D

var _is_taking_damage: bool = false
var _last_velocity: Vector2 = Vector2.ZERO


func _ready() -> void:
	if anim_player:
		anim_player.speed_scale = randf_range(0.5, 1.1)


## Called by the character's physics process to update movement animations.
func update_movement(current_velocity: Vector2):
	if _is_taking_damage:
		return
	
	if not anim_player:
		return
	
	var base_scale := Vector2.ONE
	if owner is BaseEnemy and owner.base_sprite_scale:
		base_scale = owner.base_sprite_scale
	
	if current_velocity.length_squared() > 0.01:
		var move_anim = anims_prefix + "moving"
		if anim_player.has_animation(move_anim) and anim_player.current_animation != move_anim:
			anim_player.play(move_anim)
		
		if sprite:
			if current_velocity.x > 0.1:
				sprite.flip_h = true
			elif current_velocity.x < -0.1:
				sprite.flip_h = false
			
			var target_skew = clamp(current_velocity.x * 0.00025, -0.1, 0.1)
			sprite.skew = lerp(sprite.skew, target_skew, 0.1)
	else:
		var idle_anim = anims_prefix + "idle"
		if anim_player.has_animation(idle_anim) and anim_player.current_animation != idle_anim:
			anim_player.play(idle_anim)
	
	_last_velocity = current_velocity

# Connect these in the character's _ready() function.
func on_entity_died() -> void:
	if not anim_player:
		owner.queue_free()
		return
	
	var death_anim = anims_prefix + "death"
	if anim_player.has_animation(death_anim):
		anim_player.play(death_anim)
		await anim_player.animation_finished
	
	owner.queue_free()


func on_taking_damage(_dmg: float) -> void:
	if not anim_player:
		return
	
	_is_taking_damage = true
	
	var hurt_anim = anims_prefix + "hurt_start"
	if anim_player.has_animation(hurt_anim):
		anim_player.play(hurt_anim)
		await anim_player.animation_finished
	
	# Check if the entity is still alive before resetting the flag
	if is_instance_valid(owner):
		var health_comp = owner.get_node_or_null("HealthComponent")
		if health_comp and not health_comp.is_dead():
			_is_taking_damage = false