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
	RunData.time_updated.connect(update_timer_label)

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
	var progress = minf(float(new_amount) / GameState.upgrade_shop_spawn_divisor, 1.0)
	var tween = create_tween().set_ease(Tween.EASE_OUT)
	tween.tween_property(next_upgrade_bar, "value", progress, 0.3)


func update_timer_label(time) -> void:
	@warning_ignore("integer_division")
	var minutes : int = time / 60
	var seconds : int = time % 60
	timer_label.text = TIMER_FORMAT % [minutes, seconds]


func update_currency_label(val: int) -> void:
	currency_label.text = GameState.get_currency_bbcode() + str(val)


func check_time_condition() -> void:
	#FIXME: Temp Upgrade condition, fix it later
	if RunData.research_points / RunData.upgrade_shop_spawn_divisor > 1.0 and RunData.research_points != 0 and !GameState.is_in_shop:
		RunData.upgrade_shop_spawn_divisor += 10 + (10 * (RunData.elapsed_time * 0.001))
		#Hack: also some kind of sound for sure (in layer only)
		add_child(UpgradesLayer.new_upgrade_layer())
	
	
#region Signals

func _on_timer_timeout() -> void:
	check_time_condition()

func _on_guns_button_pressed() -> void:
	RunData.player.inventory_component.switch_to_next_gun()
#endregion
