class_name FriendAttack extends FriendState



func Enter():
	enemy = find_closest_enemy()
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_parallel()
	tween.tween_property(friend, "modulate", Color.TRANSPARENT , 0.25)
	var attack = Attack.new()
	attack.attack_damage = 999
	enemy.hitbox_component.damage(attack)
	#friend.get_parent().call_deferred("remove_child", friend)
	if friend.modulate == Color.TRANSPARENT: friend.queue_free()
 
func state_process(_delta: float):
	pass
	#fixme: Have to have a consume animation for wbc (white blood cell)

	
