#hack: Display ammo_count (reload status optional)
#hack: touch_button_changing_icons...
#Todo: WBC movement and texture like a ameoba(looks and anims in the direction of mov..)
class_name HUD extends CanvasLayer

const TIMER_FORMAT = "%02d:%02d"
var pop_up_on_screen = false

@onready var slow_time_button: Button = %SlowTimeButton
@onready var screen_blast_button: Button = %ScreenBlastButton
@onready var heal_button: Button = %HealButton
@onready var invincible_button : Button = %InvincibleButton
@onready var timer_label: Label = %TimerLabel
@onready var player : Player = get_tree().get_first_node_in_group("Player")
@onready var currency_label: RichTextLabel = %CurrencyLabel

var elapsed_time = 0

func update_timer_label() -> void:
	@warning_ignore("integer_division")
	var minutes = elapsed_time / 60
	var seconds = elapsed_time % 60
	timer_label.text = TIMER_FORMAT % [minutes, seconds]

func update_hud() -> void:
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
	if GameState.research_points / GameState.upgrade_shop_spawn_divisor > 1.0 and GameState.research_points != 0:
		GameState.upgrade_shop_spawn_divisor += 10 + (10 * (elapsed_time * 0.001))
		var upgrades_scene = load("res://scenes/UI/upgrades_layer.tscn").instantiate()
		#hack: Add it like a pop up like a 0.01 sec anim? also some kind of sound for sure
		add_child(upgrades_scene)
	
	
	# Win condition
	if elapsed_time == 300:
		if !pop_up_on_screen:
			pop_up_on_screen = true
			ScreenEffects.transition("circleIn")
			await ScreenEffects.transition_player.animation_finished
			var win_scene = load("res://scenes/UI/win_screen.tscn").instantiate()
			add_child(win_scene)
			ScreenEffects.transition("circleOut")

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
	Input.action_press("switch-weapon")
	await get_tree().create_timer(0.01).timeout
	Input.action_release("switch-weapon")
	pass  # Hack: THe pic changes to the currently held gun
#endregion
