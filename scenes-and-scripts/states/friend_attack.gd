class_name FriendAttack extends FriendState



func Enter():
	enemy = find_closest_enemy()
 
func state_process(_delta: float):
	#Have to have a consume animation for wbc
	friend.get_parent().remove_child(self)
	friend.queue_free()
	enemy.queue_free()
