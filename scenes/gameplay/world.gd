#Fixed?: Gun rotating weirdly
#HACK: Use prophyliptics to make anti-bodies/ buy anti-bodies?
#hack: the final secret boss is the rogue multiplying xenobot (like how cancer cells are just rogue human cells) (could make a lore story based on this...)
#HACK: can make an icon also for touchscreenbutton/changeGunButton
#hack: (not imp due to diff bullet speeds) Changing bullet icons like nuclear throne will feel like bullets are doing different dmg
#hack: Collision bouncing in the direction of collision direction for specific bullets? or a new bullet spawns from whom it last hit.
#heartbeast video for making the sawblades balloon game (Collision bouncing in the direction of collision direction)
#Powerups only in singleplayer
# when new difficulty is unlocked for all kinds of viruses, achievement can be like: little did he know, the stronger ones were good at hiding 
#hack:A gamemode, You can only move a certain amt in a certain amt of time, (experiment until its fun)
#HACK: Player's gun doesnt slow down on slow_time powerup [upgraded! or an ultra augment (like after defeating bosses?]
#TODO: Add a upgrade that makes you damage enemies on contact
#TODO: Use backward curves for the bullets speed to decrease as time goes on...
#hack: if memory available (>90%), let upgrades layer stay, or else free from memory.
#HACK: Give a first timer tutorial where how T works is told by a video? and Add a fast moving enemy in the end so the player dies, and for every new gun he gets, he will defeat a new wave (previously not impossible, but insane)
#TODO: Bazooka, destroys obstacles instantly?
#  Show like every enemy change like infurry runner
#hack: Add a non-heavy graphics type and normal type, if menu fps above 450 fps, use normal type?

# Common sounds
	#button_hover,
	#button_down,
	#button_up,
	#button_click,
	#pickup_initial,
	#pickup_collected,
	#hit,
	#lose,
	#win,
	#mouse_down,
	#mouse_up,
	#transition_in,
	#transition_out,


class_name World extends Node2D

const NORMAL_TIME = 1.0
const SLOW_TIME = 0.75
const SLOW_DURATION = 4.0
const TRANSITION_DURATION = 0.3

@onready var time_scale_tween: Tween

@onready var animation_player := %AnimationPlayer
#@onready var time_scale_tween: Tween


@onready var hud: HUD = %HUD
@onready var out_of_view_spawn_location: PathFollow2D = %OutOfViewSpawnLocation
@onready var player: Player = %Player
@onready var enemies_node: Node2D = %EnemiesNode
@onready var powerups_node: Node2D = %PowerupsNode
@onready var enemy_spawn_timer: Timer = %EnemySpawnTimer
@onready var powerup_spawn_timer: Timer = %PowerupSpawnTimer

var current_gun_index: int = 0
var thrown_guns: Array[PackedScene] = []
var guns: Array[GunData] = []
var random_autoscroll_speed: Vector2 = Vector2(randf_range(-500, 500), randf_range(-500, 500))

func _ready() -> void:
	RunData.reset()
	_on_autoscroll_timer_timeout()
	RunData.time_updated.connect(_on_elapsed_time_updated)
	RunData.research_points_updated.connect(_on_research_points_changed)
	
	RunData.spawnable_enemies = CollectionManager.get_enemy_dict_by_spawn_order()


func _on_research_points_changed(new_amount: int):
	# Check if it's time to show the upgrade shop
	if new_amount >= RunData.upgrade_shop_spawn_divisor and not RunData.is_in_shop:
		RunData.upgrade_shop_spawn_divisor += 10 + (10 * (RunData.elapsed_time * 0.001))
		UIManager.push_layer(load("uid://24v2w4t8hgkl")) # Push UpgradesLayer scene

func _on_elapsed_time_updated(new_time: int):
	# Win condition (temp)
	if new_time == 300: #NOTE: Using >= causes it to show up every frame when continuing
		ScreenEffects.transition("circleIn")
		await ScreenEffects.transition_player.animation_finished
		UIManager.push_layer(load("uid://degok78oygxw3"))
		ScreenEffects.transition("circleOut")
		
		## Stop timers so this only happens once
		#%EnemySpawnTimer.stop()
		#%PowerupSpawnTimer.stop()


func _on_autoscroll_timer_timeout() -> void:
	random_autoscroll_speed = Vector2(randf_range(-20, 20), randf_range(-20, 20))
	var tween : Tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(%BackgroundParallax2D, "autoscroll", %BackgroundParallax2D.autoscroll + random_autoscroll_speed, 15)
	#TODO: Make the bigger parts stay constant and the smaller things move? or just add a background layer that doesnt move so it doesnt cause dizzyness

func _on_enemy_spawn_timer_timeout() -> void:
	spawn_enemy()

func time_based_enemy_type_changer() -> void:
	match RunData.elapsed_time:
		15:
			RunData.enemy_spawn_type_range.y = 2
			enemy_spawn_timer.wait_time = 3
		45:
			RunData.enemy_spawn_type_range.y = 3
			enemy_spawn_timer.wait_time = 3.5
		75: 
			RunData.enemy_spawn_type_range.y = 4
			enemy_spawn_timer.wait_time = 4
		100:
			RunData.enemy_spawn_type_range.y = 4
			enemy_spawn_timer.wait_time = 2.5
		125:
			RunData.enemy_spawn_type_range.y = 5
		#_:
			#enemy_spawn_timer.wait_time = max(enemy_spawn_timer.wait_time - 0.01, 0.5)
			#if enemy_spawn_timer.wait_time == 0.5:
				#CharacterStats.modify_stat(CharacterStats.Stats.FLAT_ENEMY_HEALTH_REDUCTION, CharacterStats.Operation.ADD, -0.1)

func _process(delta: float) -> void:
	pass
	#time_based_enemy_type_changer()

func _on_powerup_spawn_timer_timeout() -> void:
	powerup_spawn_timer.start()
	spawn_powerup()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch-weapon"):
		switch_weapon()
	elif event.is_action_pressed("throw_weapon"):
		throw_or_remove_gun_from_player(true)
	elif event.is_action_pressed("pick_up_weapon"):
		pick_up_weapon()

func spawn_enemy() -> void:
	out_of_view_spawn_location.progress_ratio = randf()
	
	enemies_node.add_child(EnemySpawner.spawn_enemy(EnemySpawner.get_random_by_spawn_chance(), out_of_view_spawn_location.global_position))

func spawn_powerup() -> void:
	out_of_view_spawn_location.progress_ratio = randf()
	
	var powerup_data : PowerupData = get_random_powerup()
	var powerup_instance : Powerup = Powerup.create_new_powerup(powerup_data)
	powerup_instance.global_position = out_of_view_spawn_location.global_position
	powerups_node.add_child(powerup_instance)

func get_random_powerup() -> PowerupData:
	#TODO: Replace randfs in the powertype scene or script (as a static fn?) itself or implement a better version
	var powerup_data: PowerupData = CollectionManager.all_powerups.values().pick_random()
	if powerup_data.spawn_chance_percent / 100 < randf():
		powerup_data = get_random_powerup()
	return powerup_data

func switch_weapon() -> void:
	if guns.size() != 0:
		current_gun_index = (current_gun_index + 1) % guns.size()
		player.base_gun.queue_free()
		var gun_instance: BaseGun
		if guns[current_gun_index] is ShotgunData:
			gun_instance = preload("uid://rks5cvegm0tb").instantiate()
		else:
			gun_instance = preload("uid://djr17spwfqlsu").instantiate()
		gun_instance.gun_data = guns[current_gun_index]
		player.base_gun = gun_instance
		player.add_child(player.base_gun)

func throw_or_remove_gun_from_player(throw: bool = true) -> void:
	if guns.size() != 0:
		var thrown_weapon : BaseGun = player.base_gun
		var thrown_weapon_scene : GunData = guns[current_gun_index]
		if thrown_weapon:
			guns.erase(thrown_weapon_scene)
		if throw:
			thrown_guns.append(thrown_weapon_scene)
			thrown_weapon.reparent(self)
			thrown_weapon.remove_from_group("Weapons")
			thrown_weapon.add_to_group("Dropped Weapons")
		switch_weapon()
		

func pick_up_weapon() -> void:
	#Todo: When near the gun, it is highlighted, so that it can be clicked.
	print(thrown_guns.size())
	if thrown_guns.size() > 0:
		var weapon : BaseGun = get_tree().get_first_node_in_group("Dropped Weapons")
		add_child(weapon)
		weapon.remove_from_group("Dropped Weapons")
		weapon.add_to_group("Weapons")
		get_tree().call_group("Weapons", "queue_free")
		guns.append(thrown_guns.pop_back())
	else:
		switch_weapon()


func use_powerup(powerup_type: StringName) -> void:
	if RunData.powerups[powerup_type] > 0:
		RunData.powerups[powerup_type] -= 1
		match powerup_type:
			&"slow_time_powerup":
				if Engine.time_scale == 1:
					activate_slow_motion()
				else:
					RunData.powerups[powerup_type] += 1
			&"screen_blast_powerup":
				ScreenEffects.transition("slightFlash")
				get_tree().call_group("On Screen Enemies", "queue_free")
				ScreenEffects.screen_shake(1, 2.5)
			&"heal_powerup":
				player.health_component.heal_or_damage(20)
			&"temp_invincible_powerup":
				player.health_component.disable_for_secs(20)
		#hud.update_hud_buttons()

func start_gun_trial(gun: GunData) -> void:
	# Instance the trial scene
	var trial_scene : Node = load("uid://b6gtyg4gve1j").instantiate()
	trial_scene.trial_gun = gun
	trial_scene.trial_completed.connect(_on_trial_completed.bind(gun))
	add_child(trial_scene)

func _on_trial_completed(success: bool, gun: GunData) -> void:
	if success:
		GameState.unlock_gun(gun)
		guns.append(gun)
		# Show success message
		print("Gun unlocked!")
	else:
		# Show failure message
		print("Trial failed! Try again!")

func activate_slow_motion() -> void:
	if Engine.time_scale == NORMAL_TIME:
		time_scale_tween = create_tween()
		time_scale_tween.tween_property(Engine, "time_scale", SLOW_TIME, TRANSITION_DURATION)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_OUT)
		
		# Play visual effects
		animation_player.play("slow_motion_start")
		#vignette.visible = true
		player.base_gun.set_ignore_time_scale()
		
		#Fixme: Play sound effect
		#play_slow_motion_sound()
		
		# Wait for duration then deactivate
		await get_tree().create_timer(SLOW_DURATION).timeout
		deactivate_slow_motion()

func deactivate_slow_motion() -> void:
	if !GameState.is_in_shop:
		time_scale_tween = create_tween()
		time_scale_tween.tween_property(Engine, "time_scale", NORMAL_TIME, TRANSITION_DURATION)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN)
			
		player.base_gun.unset_ignore_time_scale()
	animation_player.play("slow_motion_end")
	#vignette.visible = false
	
	#FIXME: play_normal_time_sound where it plays right before the timer is about to end (like star powerups in super mario)
