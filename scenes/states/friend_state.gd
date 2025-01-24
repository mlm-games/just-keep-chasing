class_name FriendState extends State

@export var friend : CharacterBody2D
@export var move_speed := 140.0

var enemy: CharacterBody2D
var distance: float

func find_closest_enemy():
	var enemies = get_tree().get_nodes_in_group("Enemies")
	var closest_enemy = null
	var closest_distance = INF

	for foe in enemies:
		distance = friend.global_position.distance_to(foe.global_position)
		if distance < closest_distance:
			closest_distance = distance
		closest_enemy = foe

	return closest_enemy
