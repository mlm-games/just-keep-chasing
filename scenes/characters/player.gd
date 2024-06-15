class_name Player extends CharacterBody2D

@export var speed = 250

var powerups = {
	GameState.PowerupType.SLOW_TIME: 0,
	GameState.PowerupType.SCREEN_BLAST: 0,
	GameState.PowerupType.HEAL: 0
}

@onready var health_component: HealthComponent = %HealthComponent
@onready var camera: Camera2D = %Camera2D
@onready var progress_bar: ProgressBar = %ProgressBar

func _physics_process(_delta):
	var direction = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	velocity = direction.normalized() * Vector2(speed, speed)
	if velocity.x > 0:
		%Sprite2D.flip_h = true
	elif velocity.x < 0:
		%Sprite2D.flip_h = false
	move_and_slide()

func _on_health_component_player_died() -> void:
	hide()
	process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(0.5).timeout
	ScreenEffects.change_scene_with_transition("res://scenes/UI/game_over_screen.tscn", "circleIn")

func _on_health_component_taking_damage() -> void:
	ScreenEffects.screen_shake(0.1, 0.5, camera)

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

func powerup_collected(powerup_type: int) -> void:
	powerups[powerup_type] += 1
	get_parent().update_hud()


func _on_health_component_health_changed(new_health: float) -> void:
	%ProgressBar.value = new_health
