class_name FriendFollow extends FriendState



func Enter():
	pass
 
func state_process(_delta: float):
	var direction
	enemy = find_closest_enemy()
	if enemy:
		direction = enemy.global_position - friend.global_position
	
	if direction:
		if direction.length() > 5:
			friend.velocity = direction.normalized() * move_speed
		else:
			friend.velocity = Vector2.ZERO
			
		if direction.length() > 1500:
			transitioned.emit(self, "idle")
			
		elif direction.length() < 150:
			transitioned.emit(self, "attack")
			




