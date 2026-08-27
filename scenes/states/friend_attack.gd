class_name FriendAttack extends FriendState



func Enter():
	enemy = find_closest_enemy()
	if not enemy or not is_instance_valid(enemy):
		friend.queue_free()
		return
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_parallel()
	tween.tween_property(friend, "modulate", Color.TRANSPARENT , 0.25)
	var attack = Attack.new()
	attack.attack_damage = 999
	var hitbox = enemy.get_node_or_null("HitboxComponent") or enemy.get_node_or_null("%EnemyHitboxComponent")
	if hitbox:
		hitbox.damage(attack)
	
 
func state_process(_delta: float):
	if friend.modulate == Color.TRANSPARENT: friend.queue_free()

	
