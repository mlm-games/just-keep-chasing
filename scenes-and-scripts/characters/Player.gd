extends CharacterBody2D

@export var speed = Vector2(250,250)
@export var guns: Array[PackedScene] = []

var gun_no: int = 0

@onready var health_component: HealthComponent = %HealthComponent


func _physics_process(_delta):
	#Movement
	%ProgressBar.value = health_component.current_health
	var direction = Input.get_vector("ui_left","ui_right","ui_up","ui_down")
	velocity = direction.normalized() * speed
	move_and_slide()


func _on_health_component_player_died() -> void:
	#Cant queue free as player is needed for enemy pathfinding
	self.hide()
	self.process_mode = Node.PROCESS_MODE_DISABLED
	await get_tree().create_timer(0.5).timeout
	get_tree().quit() #just for now


func _on_health_component_taking_damage() -> void:
	Utils.screen_shake(0.1, 0.5, %Camera2D)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch-weapon"):
		if (gun_no < guns.size() - 1):
			gun_no += 1
		else:
			gun_no = 0
		print(gun_no)
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
