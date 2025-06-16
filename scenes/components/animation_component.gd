## Manages a character's animations by listening to other components.
class_name AnimationComponent extends Node

# Assign these nodes from the character scene that owns this component.
@export var anim_player: AnimationPlayer
@export var sprite: Sprite2D

# STATE VARIABLES
var _is_taking_damage: bool = false
var _last_velocity: Vector2 = Vector2.ZERO


## Called by the character's physics process to update movement animations.
func update_movement(current_velocity: Vector2):
	if _is_taking_damage:
		# Don't play movement animations while the hurt animation is active.
		return

	if current_velocity.length_squared() > 0:
		# Play move animation if not already playing
		if anim_player.current_animation != "moving":
			anim_player.play("moving")
		
		# Flip the sprite based on horizontal movement direction
		if sprite:
			if current_velocity.x > 0.1:
				sprite.flip_h = true
			elif current_velocity.x < -0.1:
				sprite.flip_h = false
	else:
		# Play idle animation if not already playing
		if anim_player.current_animation != "idle":
			anim_player.play("idle")

	_last_velocity = current_velocity

# Connect these in the character's _ready() function.
func on_entity_died():
	anim_player.play("death")
	await anim_player.animation_finished
	owner.queue_free() # The component is responsible for freeing its owner after death anim.

func on_taking_damage():
	_is_taking_damage = true
	anim_player.play("hurt_start")
	await anim_player.animation_finished
	# Check if the entity is still alive before resetting the flag
	if is_instance_valid(owner) and not owner.health_component.is_dead():
		_is_taking_damage = false
