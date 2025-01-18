class_name FriendAttack extends FriendState



func Enter():
	enemy = find_closest_enemy()
 
func state_process(_delta: float):
	#Have to have a consume animation for wbc (white blood cell)
	if enemy: enemy.queue_free()
	friend.get_parent().call_deferred("remove_child", friend)
	friend.queue_free()
	
