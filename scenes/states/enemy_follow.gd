class_name EnemyFollow extends State

@export var enemy : CharacterBody2D
@export var move_speed := 40.0

var player: CharacterBody2D

func Enter():
	player = A.tree.get_first_node_in_group("Player")
 
func state_process(_delta: float):
	var direction = player.global_position - enemy.global_position
	
	if direction.length() > 0:
		enemy.velocity = direction.normalized() * move_speed
	else:
		enemy.velocity = Vector2.ZERO
		
	if direction.length() > 150:
		transitioned.emit(self, "idle")
		
