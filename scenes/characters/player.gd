class_name Player extends CharacterBody2D

@onready var health_component: HealthComponent = %HealthComponent
@onready var progress_bar: ProgressBar = %ProgressBar
@onready var animation_tree: AnimationTree = $AnimationTree

var taking_damage : bool = false
var base_gun: BaseGun

func _ready() -> void:
	var initial_gun_data: GunData = GameState.collection_res.guns["pistol"]
	base_gun = initial_gun_data.weapon_scene.instantiate()
	base_gun.gun_data = initial_gun_data
	add_child(base_gun)
	
	# Initialize health with game stats
	update_max_health(GameStats.get_stat(GameStats.Stats.PLAYER_MAX_HEALTH))

func _physics_process(_delta: float) -> void:
	var direction : Vector2 = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if GameState.movement_joystick_direction != Vector2.ZERO:
		direction = GameState.movement_joystick_direction
	
	velocity = direction.normalized() * GameStats.get_stat(GameStats.Stats.PLAYER_SPEED)
	
	if velocity.x > 0:
		%Sprite2D.flip_h = true
	elif velocity.x < 0:
		%Sprite2D.flip_h = false
		
	
	move_and_slide()

func _on_health_component_entity_died() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(0.5).timeout
	ScreenEffects.change_scene_with_transition("res://scenes/UI/game_over_screen.tscn", "circleIn")

func _on_health_component_taking_damage() -> void:
	taking_damage = true
	ScreenEffects.screen_shake(0.1, 0.5)
	await get_tree().create_timer(0.1).timeout
	taking_damage = false


func _on_health_component_health_changed(new_health: float) -> void:
	%ProgressBar.value = new_health

func update_max_health(new_max_health: float) -> void:
	%ProgressBar.max_value = new_max_health
	health_component.max_health = new_max_health
	
#func on_save_game(saved_data: Array[SaveData]):
	#if health_component.is_alive():
		#var my_data = CharacterSaveData.new()
		#my_data.position = global_position
		#my_data.current_health = health_component.current_health
		#saved_data.append(my_data)
#
#func before_load_game():
	#if health_component.is_alive():
		#get_parent().remove_child(self)
		#queue_free()
#
#func on_load_game(saved_data: CharacterSaveData):
	#if saved_data:
		#global_position = saved_data.global_position
		#health_component.current_health = saved_data.current_health
