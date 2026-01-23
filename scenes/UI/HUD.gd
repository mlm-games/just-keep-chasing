#hack: Display ammo_count (reload status optional)
#hack: touch_button_changing_icons...
class_name HUD extends CanvasLayer

static var I: HUD

func _init() -> void:
	I = self

const TIMER_FORMAT = "%02d:%02d"

@onready var slow_time_button: Button = %SlowTimeButton
@onready var screen_blast_button: Button = %ScreenBlastButton
@onready var heal_button: Button = %HealButton
@onready var invincible_button: Button = %InvincibleButton
@onready var timer_label: Label = %TimerLabel
@onready var currency_label: RichTextLabel = %CurrencyLabel
@onready var next_upgrade_bar: ProgressBar = %NextUpgradeBar

var pop_up_on_screen: bool = false


func _ready() -> void:
	RunData.mito_energy_updated.connect(_on_mito_energy_updated)
	RunData.time_updated.connect(_on_time_updated)
	%GameTimer.timeout.connect(func(): RunData.elapsed_time += 1)
	
	# Update initial display
	update_currency_label(RunData.mito_energy)
	update_timer_label(RunData.elapsed_time)


func _on_mito_energy_updated(val: int) -> void:
	update_currency_label(val)
	update_progress_bar(val)


func _on_time_updated(val: int) -> void:
	update_timer_label(val)


func update_progress_bar(new_amount: int) -> void:
	var progress = minf(float(new_amount) / RunData.upgrade_shop_spawn_divisor, 1.0)
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_ignore_time_scale()
	tween.tween_property(next_upgrade_bar, "value", progress, 0.3)


func update_timer_label(time: int) -> void:
	@warning_ignore("integer_division")
	var minutes: int = time / 60
	var seconds: int = time % 60
	timer_label.text = TIMER_FORMAT % [minutes, seconds]


func update_currency_label(val: int) -> void:
	var current_val = int(currency_label.text.trim_prefix(GameState.get_currency_bbcode()))
	UIEffects.animate_number(currency_label, current_val, val, GameState.get_currency_bbcode(), 0.1).set_ease(Tween.EASE_IN)


func update_powerup_buttons() -> void:
	slow_time_button.text = str(RunData.powerups.get(&"slow_time_powerup", 0))
	screen_blast_button.text = str(RunData.powerups.get(&"screen_blast_powerup", 0))
	heal_button.text = str(RunData.powerups.get(&"heal_powerup", 0))
	invincible_button.text = str(RunData.powerups.get(&"temp_invincible_powerup", 0))


#region Button Signal Handlers

func _on_slow_time_button_pressed() -> void:
	if World.I:
		World.I.use_powerup(&"slow_time_powerup")
		update_powerup_buttons()


func _on_screen_blast_button_pressed() -> void:
	if World.I:
		World.I.use_powerup(&"screen_blast_powerup")
		update_powerup_buttons()


func _on_heal_button_pressed() -> void:
	if World.I:
		World.I.use_powerup(&"heal_powerup")
		update_powerup_buttons()


func _on_invincible_button_pressed() -> void:
	if World.I:
		World.I.use_powerup(&"temp_invincible_powerup")
		update_powerup_buttons()


func _on_guns_button_pressed() -> void:
	UiAudioManager.play_ui_sound(preload("res://assets/music/gun sounds by q009/weapswitch.ogg"))
	if Player.I:
		Player.I.inventory_component.switch_to_next_gun()

#endregion


func check_time_condition(time: int) -> void:
	#FIXME: Temp Upgrade condition, fix it later
	if RunData.mito_energy / RunData.upgrade_shop_spawn_divisor > 1.0 and RunData.mito_energy != 0 and !GameState.is_in_shop:
		RunData.upgrade_shop_spawn_divisor += 10 + (10 * (RunData.elapsed_time * 0.001))
		#Hack: also some kind of sound for sure (in layer only)
		add_child(UpgradesLayer.new_upgrade_layer())
