#hack: Display ammo_count (reload status optional)
#hack: touch_button_changing_icons...
class_name HUD extends CanvasLayer

const TIMER_FORMAT = "%02d:%02d"
var pop_up_on_screen : bool = false

@onready var slow_time_button: Button = %SlowTimeButton
@onready var screen_blast_button: Button = %ScreenBlastButton
@onready var heal_button: Button = %HealButton
@onready var invincible_button : Button = %InvincibleButton
@onready var timer_label: Label = %TimerLabel
@onready var player : Player = get_tree().get_first_node_in_group("Player")
@onready var currency_label: RichTextLabel = %CurrencyLabel
@onready var next_upgrade_bar: ProgressBar = %NextUpgradeBar

func _ready() -> void:
	RunData.research_points_updated.connect(func(val): update_currency_label(val); update_progress_bar(val))
	RunData.time_updated.connect(func(val): update_timer_label(val); check_time_condition(val))
	%GameTimer.timeout.connect(func(): RunData.elapsed_time += 1)

var progress_bar_tween: Tween

#func _ready() -> void:
	#if GameState.gameplay_options["hide_touch_buttons"]:
		#slow_time_button.hide()
		#screen_blast_button.hide()
		#heal_button.hide()
		#invincible_button.hide()

#@onready var powerup_buttons: Dictionary = {
	#0: %SlowTimeButton, 1: %ScreenBlastButton, ... .
#}
#
#func update_hud_buttons():
	#for i in powerup_buttons:
		#powerup_buttons[i].text = str(GameState.powerups[i])

func update_progress_bar(new_amount: int) -> void:
	var progress = minf(float(new_amount) / RunData.upgrade_shop_spawn_divisor, 1.0)
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_ignore_time_scale()
	tween.tween_property(next_upgrade_bar, "value", progress, 0.3)


func update_timer_label(time: int) -> void:
	@warning_ignore("integer_division")
	var minutes : int = time / 60
	var seconds : int = time % 60
	timer_label.text = TIMER_FORMAT % [minutes, seconds]


func update_currency_label(val: int) -> void:
	UIEffects.animate_number(currency_label, int(currency_label.text.trim_prefix(GameState.get_currency_bbcode())), val, GameState.get_currency_bbcode(), 0.1)


func check_time_condition(time:int) -> void:
	#FIXME: Temp Upgrade condition, fix it later
	if RunData.research_points / RunData.upgrade_shop_spawn_divisor > 1.0 and RunData.research_points != 0 and !GameState.is_in_shop:
		RunData.upgrade_shop_spawn_divisor += 10 + (10 * (RunData.elapsed_time * 0.001))
		#Hack: also some kind of sound for sure (in layer only)
		add_child(UpgradesLayer.new_upgrade_layer())


#region Signals

func _on_guns_button_pressed() -> void:
	UiAudioM.play_ui_sound(preload("res://assets/music/gun sounds by q009/weapswitch.ogg"))
	RunData.player.inventory_component.switch_to_next_gun()
#endregion
