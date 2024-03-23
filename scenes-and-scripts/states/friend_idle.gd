class_name FriendIdle extends FriendState


@export var idle_time : Vector2 = Vector2(1,3)
@export var wander_time : Vector2 = Vector2(0.5,1.5)

var move_direction : Vector2
var wander_timer : float
var idle_timer : float

func randomize_wander():
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_timer = randf_range(wander_time.x,wander_time.y)
	idle_timer = randf_range(idle_time.x,idle_time.y)



func Enter():
	randomize_wander()

func state_process(delta: float):
	if wander_timer > 0:
		wander_timer -= delta
	elif idle_timer > 0:
		idle_timer -= delta
	else:
		randomize_wander()


func state_physics_process(_delta: float):
	enemy = find_closest_enemy()
	if friend:
		if wander_timer > 0:
			friend.velocity = move_direction * move_speed
		elif idle_timer > 0:
			friend.velocity = Vector2.ZERO
	if enemy != null:
		var direction = enemy.global_position - friend.global_position
		if direction.length() < 1500:
			transitioned.emit(self, "follow")
