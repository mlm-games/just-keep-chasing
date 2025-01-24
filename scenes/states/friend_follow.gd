class_name FriendFollow extends FriendState



func Enter():
	enemy = find_closest_enemy()
 
func state_process(_delta: float):
	var direction : Vector2
	if enemy:
		direction = enemy.global_position - friend.global_position
	else: 
		enemy = find_closest_enemy()
	
	if direction.length():
		if direction.length() > 15:
			friend.velocity = direction.normalized() * move_speed
			friend.rotation = lerp_angle(friend.rotation, direction.angle(), 0.1)
			friend.rotation = wrapf(friend.rotation, -PI/2, 3*PI/2)
		else:
			transitioned.emit(self, "attack")
			friend.velocity = Vector2.ZERO
			
		if direction.length() > 1500:
			transitioned.emit(self, "idle")
		elif direction.length() < 100:
			enemy.speed = lerpf(enemy.speed, 0, 0.02)
			
			
