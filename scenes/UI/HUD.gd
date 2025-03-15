#hack: Display ammo_count (reload status optional)
#hack: touch_button_changing_icons...
class_name HUD extends CanvasLayer

const TIMER_FORMAT = "%02d:%02d"
var pop_up_on_screen : bool = false
var touching : bool = false
var initial_touch_position : Vector2

@onready var slow_time_button: Button = %SlowTimeButton
@onready var screen_blast_button: Button = %ScreenBlastButton
@onready var heal_button: Button = %HealButton
@onready var invincible_button : Button = %InvincibleButton
@onready var timer_label: Label = %TimerLabel
@onready var player : Player = get_tree().get_first_node_in_group("Player")
@onready var currency_label: RichTextLabel = %CurrencyLabel

var elapsed_time : int = 0


#func _ready() -> void:
	#if GameState.gameplay_options["hide_touch_buttons"]:
		#slow_time_button.hide()
		#screen_blast_button.hide()
		#heal_button.hide()
		#invincible_button.hide()

func update_timer_label() -> void:
	@warning_ignore("integer_division")
	var minutes : int = elapsed_time / 60
	var seconds : int = elapsed_time % 60
	timer_label.text = TIMER_FORMAT % [minutes, seconds]

func update_hud_buttons() -> void:
	#if !GameState.gameplay_options["hide_touch_buttons"]:
		update_slow_time_button()
		update_screen_blast_button()
		update_heal_button()
		update_invincible_button()

func update_currency_label() -> void:
	currency_label.text = GameState.get_currency_bbcode() + str(GameState.research_points)
#Fixme: Use enums or There should be another way to remove these redundant functions below
func update_slow_time_button() -> void:
	slow_time_button.text = str(GameState.powerups[0])

func update_screen_blast_button() -> void:
	screen_blast_button.text = str(GameState.powerups[1])

func update_heal_button() -> void:
	heal_button.text = str(GameState.powerups[2])

func update_invincible_button() -> void:
	invincible_button.text = str(GameState.powerups[3])

func check_time_condition() -> void:
	#FIXME: Temp Upgrade condition, fix it later
	if GameState.research_points / GameState.upgrade_shop_spawn_divisor > 1.0 and GameState.research_points != 0 and !GameState.is_in_shop:
		GameState.upgrade_shop_spawn_divisor += 10 + (10 * (elapsed_time * 0.001))
		var upgrades_scene : Node = load("uid://24v2w4t8hgkl").instantiate()
		#Hack: also some kind of sound for sure
		add_child(upgrades_scene)
	
	
	# Win condition
	if elapsed_time == 300:
		if !pop_up_on_screen:
			pop_up_on_screen = true
			ScreenEffects.transition("circleIn")
			await ScreenEffects.transition_player.animation_finished
			var win_scene : Node = load("uid://degok78oygxw3").instantiate()
			add_child(win_scene)
			ScreenEffects.transition("circleOut")

func _input(event: InputEvent) -> void:
	##print(event.get_class())
	if event is InputEventMouseButton and !touching and event.is_pressed():
		touching = true
		initial_touch_position = event.position
		if event.position < (get_viewport().get_visible_rect().position + get_viewport().get_visible_rect().size)/2: # Only work if touching on left half of screen
			%MovementJoystickSprite2D._assign_start_point(event.position)
		else:
			%ShootingJoystickSprite2D._assign_start_point(event.position)
			
	elif event is InputEventMouseButton:
		touching = false
		%MovementJoystickSprite2D.hide()
		%ShootingJoystickSprite2D.hide()
				#Dont include the below line to keep the player moving in the last direction after release
		GameState.movement_joystick_direction = Vector2.ZERO
		
	## Doesnt work
	#elif event is InputEventMouseButton and event.is_double_click():
		#Input.action_press("drop-weapon")
	
		
	if event is InputEventMouseMotion and touching: #remove touching for a new conrol scheme
		if %MovementJoystickSprite2D.visible: 
			%MovementJoystickSprite2D._update_target_point(event.position)
			GameState.movement_joystick_direction = (event.position - initial_touch_position).normalized()
		if %ShootingJoystickSprite2D.visible: 
			%ShootingJoystickSprite2D._update_target_point(event.position)
			GameState.shooting_joystick_direction = (event.position - initial_touch_position).normalized()
			
		


#region Signals

func _on_timer_timeout() -> void:
	elapsed_time += 1
	update_timer_label()
	check_time_condition()
	pop_up_on_screen = false
#Fixme: Getting the character upgrade screen and the game win screen causes the game to run normally with the game end screen after closing the upgrade screen.

func _on_slow_time_button_pressed() -> void:
	get_parent().use_powerup(0)
	update_slow_time_button()


func _on_screen_blast_button_pressed() -> void:
	get_parent().use_powerup(1)
	update_screen_blast_button()


func _on_heal_button_pressed() -> void:
	get_parent().use_powerup(2)
	update_heal_button()

func _on_invincible_button_pressed() -> void:
	get_parent().use_powerup(3)
	update_invincible_button()

func _on_guns_button_pressed() -> void:
	GameState.world.switch_weapon()
#endregion
