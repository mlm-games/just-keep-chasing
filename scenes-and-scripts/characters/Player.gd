extends CharacterBody2D

@export var speed = 250
@export var guns: Array[PackedScene] = []

var gun_no: int = 0
var upgraded: bool = true

@onready var health_component: HealthComponent = %HealthComponent
#HACK: upgrade to the slow time powerup doesnt slow the player down but everything else

func _physics_process(_delta):
	var direction = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	if upgraded:
		# Adjust player speed based on time scale
		var adjusted_speed = speed / Engine.time_scale
		velocity = direction.normalized() * Vector2(adjusted_speed,adjusted_speed)
	else:
		velocity = direction.normalized() * Vector2(speed,speed)
	
	%ProgressBar.value = health_component.current_health
	
	
	move_and_slide()
	
	
	
	



func _on_health_component_player_died() -> void:
	#Cant queue free as player is needed for enemy pathfinding
	self.hide()
	self.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(0.5).timeout
	var transitions = get_node_or_null("/root/Transitions")
	if transitions:
		transitions.circle_in()
		await transitions.anim.animation_finished
		await get_tree().create_timer(0.3).timeout
	get_tree().quit() #just for now

func powerup_collected() -> void:
	print("powerup obtained ")


func _on_health_component_taking_damage() -> void:
	Utils.screen_shake(0.1, 0.5, %Camera2D)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch-weapon"):
		#Scrolling through weapons
		gun_no = (gun_no + 1) % guns.size()
		print("Gun no: ", gun_no)
		get_tree().call_group("Weapons","queue_free")
		var gun_instance = guns[gun_no].instantiate()
		self.add_child(gun_instance)


func on_save_game(saved_data:Array[SaveData]):
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
