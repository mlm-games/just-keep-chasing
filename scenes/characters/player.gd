class_name Player extends CharacterBody2D

@export var speed = 250

var slow_time_powerup: int = 0
var screen_blast_powerup: int = 0
var heal_powerup: int = 0

@onready var health_component: HealthComponent = %HealthComponent
@onready var camera: Camera2D = %Camera2D

func _physics_process(_delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction.normalized() * Vector2(speed, speed)
	
	%ProgressBar.value = health_component.current_health
	
	move_and_slide()

func _on_health_component_player_died() -> void:
	#Can't free player 
	self.hide()
	self.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(0.5).timeout
	var transitions = get_node_or_null("/root/Transitions")
	if transitions:
		transitions.circle_in()
		await transitions.anim.animation_finished
		await get_tree().create_timer(0.3).timeout
		get_tree().change_scene_to_file("res://scenes/menu/menu.tscn")
		transitions.circle_out()

func _on_health_component_taking_damage() -> void:
	Utils.screen_shake(0.1, 0.5, camera)

func on_save_game(saved_data: Array[SaveData]):
	if health_component.is_alive():
		var my_data = CharacterSaveData.new()
		my_data.position = global_position
		my_data.current_health = health_component.current_health
		saved_data.append(my_data)

func before_load_game():
	if health_component.is_alive():
		get_parent().remove_child(self)
		queue_free()

func on_load_game(saved_data: CharacterSaveData):
	if saved_data:
		global_position = saved_data.global_position
		health_component.current_health = saved_data.current_health

func powerup_collected(powerup_name) -> void:
	match powerup_name:
		"slow_time":
			slow_time_powerup += 1
		"screen_blast":
			screen_blast_powerup += 1
		"heal":
			heal_powerup += 1
	get_parent().update_hud()
