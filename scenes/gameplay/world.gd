#Fixed?: Gun rotating weirdly
#HACK: Use prophyliptics to make anti-bodies/ buy anti-bodies?
#hack: the final secret boss is the rogue multiplying xenobot (like how cancer cells are just rogue human cells) (could make a lore story based on this...)
#hack: Collision bouncing in the direction of collision direction for specific bullets? or a new bullet spawns from whom it last hit.
#heartbeast video for making the sawblades balloon game (Collision bouncing in the direction of collision direction)
# when a new difficulty is unlocked for all kinds of viruses, achievement can be like: little did he know, the stronger ones were good at hiding (like real life)
#hack:A gamemode, You can only move a certain amt in a certain amt of time, (experiment until its fun)
#HACK: Player's gun doesnt slow down on slow_time powerup [upgraded! or an ultra augment (like after defeating bosses?]
#TODO: Add a upgrade that makes you damage enemies on contact
#HACK: Give a first timer tutorial where how T works is told by a video? and Add a fast moving enemy in the end so the player dies, and for every new gun he gets, he will defeat a new wave (previously not impossible, but insane [sf2 ref?])
#TODO: Bazooka destroys obstacles instantly?
#  Show every enemy timer change like in furry runner
#hack: Add a non-heavy graphics type and normal type, if menu fps is above 450 fps, use normal type?

class_name World extends Node2D

static var I: World

func _init() -> void:
	I = self

const NORMAL_TIME = 1.0
const SLOW_TIME = 0.75
const SLOW_DURATION = 4.0
const TRANSITION_DURATION = 0.3

@onready var time_scale_tween: Tween

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var out_of_view_spawn_location: PathFollow2D = %OutOfViewSpawnLocation
@onready var player: Player = %Player
@onready var enemies_node: Node2D = %EnemiesNode
@onready var powerups_node: Node2D = %PowerupsNode
@onready var enemy_spawn_timer: Timer = %EnemySpawnTimer
@onready var powerup_spawn_timer: Timer = %PowerupSpawnTimer
@onready var autoscroll_timer: Timer = %AutoscrollTimer

var current_gun_index: int = 0
var thrown_guns: Array[GunData] = []
var guns: Array[GunData] = []
var random_autoscroll_speed: Vector2 = Vector2(randf_range(-500, 500), randf_range(-500, 500))


func _ready() -> void:
	RunData.reset()
	RunData.time_updated.connect(_on_elapsed_time_updated)
	RunData.mito_energy_updated.connect(_on_mito_energy_changed)
	
	A.tree.root.focus_exited.connect(_on_focus_lost)
	enemy_spawn_timer.timeout.connect(spawn_enemy)
	powerup_spawn_timer.timeout.connect(spawn_powerup)
	autoscroll_timer.timeout.connect(_on_autoscroll_timer_timeout)
	
	RunData.spawnable_enemies = CollectionManager.get_enemy_dict_by_spawn_order()


func _on_focus_lost() -> void:
	# Only pause if we're in the world scene and not already paused
	if is_inside_tree() and not A.tree.paused:
		UIManager.pause()


func _on_mito_energy_changed(new_amount: int) -> void:
	# Check if it's time to show the upgrade shop
	if new_amount >= RunData.upgrade_shop_spawn_divisor and not RunData.is_in_shop:
		RunData.upgrade_shop_spawn_divisor += 10 + (10 * (RunData.elapsed_time * 0.001))
		UIManager.push_layer(load("uid://24v2w4t8hgkl"))


func _on_elapsed_time_updated(new_time: int) -> void:
	time_based_enemy_type_changer()
	if new_time == 300:
		CountStats.increment_stat(C.COUNT_STAT_KEYS.games_won)
		CountStats.increment_stat(C.COUNT_STAT_KEYS.games_played)
		CountStats.update_longest_run_time(new_time)
		GameState.update_highest_game_time(new_time)
		GameState.save_game()
		GameState.update_achievements()
		
		enemy_spawn_timer.stop()
		powerup_spawn_timer.stop()
		
		ScreenTransitions.transition("circleIn")
		await ScreenTransitions.transition_player.animation_finished
		var win_screen = UIManager.push_layer(load("uid://degok78oygxw3"))
		if win_screen:
			win_screen.continue_pressed.connect(_on_win_continue_pressed)
		ScreenTransitions.transition("circleOut")


func _on_win_continue_pressed() -> void:
	enemy_spawn_timer.start()
	powerup_spawn_timer.start()


func _on_autoscroll_timer_timeout() -> void:
	random_autoscroll_speed = Vector2(randf_range(-20, 20), randf_range(-20, 20))
	var tween: Tween = create_tween().set_ease(Tween.EASE_IN)
	tween.tween_property(%BackgroundParallax2D, "autoscroll", %BackgroundParallax2D.autoscroll + random_autoscroll_speed, 15)
	#TODO: Make the bigger parts stay constant and the smaller things move? or just add a background layer that doesnt move so it doesnt cause dizzyness

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
			RunData.enemy_spawn_type_range.y = 5
			enemy_spawn_timer.wait_time = 2.5
		140:
			RunData.enemy_spawn_type_range.y = 6
			enemy_spawn_timer.wait_time = 2.2
		180:
			RunData.enemy_spawn_type_range.y = 7
			enemy_spawn_timer.wait_time = 2.0
		220:
			RunData.enemy_spawn_type_range.y = 8
			enemy_spawn_timer.wait_time = 1.8

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("switch-weapon"):
		switch_weapon()
	elif event.is_action_pressed("throw_weapon"):
		throw_or_remove_gun_from_player(true)
	elif event.is_action_pressed("pick_up_weapon"):
		pick_up_weapon()
	elif event.is_action_pressed("reload") and player and player.base_gun:
		player.base_gun.reload()


func spawn_enemy() -> void:
	out_of_view_spawn_location.progress_ratio = randf()
	var enemy_data = EnemySpawner.get_random_by_spawn_chance()
	if enemy_data:
		var enemy = EnemySpawner.spawn_enemy(enemy_data, out_of_view_spawn_location.global_position)
		if enemy:
			enemies_node.add_child(enemy)


func spawn_powerup() -> void:
	out_of_view_spawn_location.progress_ratio = randf()
	
	var powerup_data: PowerupData = get_random_powerup()
	if powerup_data:
		var powerup_instance: Powerup = Powerup.create_new_powerup(powerup_data)
		powerups_node.add_child(powerup_instance)
		powerup_instance.global_position = out_of_view_spawn_location.global_position


func get_random_powerup() -> PowerupData:
	var all_powerups = CollectionManager.all_powerups.values()
	if all_powerups.is_empty():
		return null
	
	#HACK: Try up to 10 times to get a powerup based on spawn chance
	for _attempt in range(10):
		var powerup_data: PowerupData = all_powerups.pick_random()
		if is_nan(powerup_data.spawn_chance_percent) or randf() <= powerup_data.spawn_chance_percent / 100.0:
			return powerup_data
	
	# else
	return all_powerups.pick_random()


func switch_weapon() -> void:
	if player and player.inventory_component:
		player.inventory_component.switch_to_next_gun()


func throw_or_remove_gun_from_player(throw: bool = true) -> void:
	if guns.size() <= 1:
		return
	
	var thrown_weapon: BaseGun = player.base_gun
	var thrown_weapon_data: GunData = guns[current_gun_index]
	
	if thrown_weapon and thrown_weapon_data:
		guns.erase(thrown_weapon_data)
		
		if throw:
			thrown_guns.append(thrown_weapon_data)
			thrown_weapon.reparent(self)
			thrown_weapon.remove_from_group("Weapons")
			thrown_weapon.add_to_group("Dropped Weapons")
		
		switch_weapon()


func pick_up_weapon() -> void:
	if thrown_guns.is_empty():
		switch_weapon()
		return

	var weapon: BaseGun = A.tree.get_first_node_in_group("Dropped Weapons")
	if not weapon:
		return

	var weapon_data := weapon.gun_data
	if not weapon_data:
		return

	weapon.reparent(player)
	weapon.remove_from_group("Dropped Weapons")
	weapon.add_to_group("Weapons")

	guns.append(weapon_data)
	thrown_guns.erase(weapon_data)


func use_powerup(powerup_type: StringName) -> void:
	if not RunData.use_powerup(powerup_type):
		return
	
	CountStats.increment_stat(C.COUNT_STAT_KEYS.powerups_used)
	
	match powerup_type:
		&"slow_time_powerup":
			if Engine.time_scale == NORMAL_TIME:
				activate_slow_motion()
			else:
				RunData.powerups[powerup_type] += 1
		&"screen_blast_powerup":
			ScreenTransitions.transition("slightFlash")
			for enemy in A.tree.get_nodes_in_group("On Screen Enemies"):
				if enemy.has_node("HealthComponent"):
					var atk := Attack.new()
					atk.attack_damage = 9999
					enemy.get_node("HealthComponent").damage(atk)
			ScreenEffects.screen_shake(1, 2.5)
		&"heal_powerup":
			if player and player.health_component:
				player.health_component.heal_or_damage(player.health_component.max_health * 0.5, HealthComponent.HealthModificationType.HEAL)
		&"temp_invincible_powerup":
			if player and player.health_component:
				player.health_component.disable_for_secs(5.0)
		&"multi_wield_powerup":
			if player and not player.multi_wield_active:
				player.activate_multi_wield()


func start_gun_trial(gun: GunData) -> void:
	var trial_scene: Node = load("uid://b6gtyg4gve1j").instantiate()
	trial_scene.trial_gun = gun
	trial_scene.trial_completed.connect(_on_trial_completed.bind(gun))
	add_child(trial_scene)


func _on_trial_completed(success: bool, gun: GunData) -> void:
	if success:
		GameState.unlock_gun(gun)
		guns.append(gun)
		print("Gun unlocked!")
	else:
		print("Trial failed! Try again!")


func activate_slow_motion() -> void:
	if Engine.time_scale != NORMAL_TIME:
		return
	
	time_scale_tween = create_tween()
	time_scale_tween.tween_property(Engine, "time_scale", SLOW_TIME, TRANSITION_DURATION)
	time_scale_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	
	animation_player.play("slow_motion_start")
	#vignette.visible = true

	if player and player.base_gun:
		player.base_gun.set_ignore_time_scale()
		#Fixme: Play sound effect
		#play_slow_motion_sound()
		
		# Wait for duration then deactivate
	await A.tree.create_timer(SLOW_DURATION, true, false, true).timeout
	deactivate_slow_motion()


func deactivate_slow_motion() -> void:
	if RunData.is_in_shop:
		return
	
	time_scale_tween = create_tween()
	time_scale_tween.tween_property(Engine, "time_scale", NORMAL_TIME, TRANSITION_DURATION)
	time_scale_tween.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	
	if player and player.base_gun:
		player.base_gun.unset_ignore_time_scale()
	
	animation_player.play("slow_motion_end")
	#vignette.visible = false
	
	#FIXME: play_normal_time_sound where it plays right before the timer is about to end (like star powerups in super mario)
