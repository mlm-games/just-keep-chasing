extends Node2D
#FIXME: Just unlock them using achievements/quests/tasks/milestones... Virus extinction goals would be a nice name?
signal trial_completed(success: bool)

@export var trial_gun: PackedScene
@export var trial_duration: float = 120.0  # 2 minutes

@onready var timer: Timer = $Timer
@onready var player: Player = $Player

func _ready() -> void:
	setup_trial()
	timer.start(trial_duration)

func setup_trial() -> void:
	# Give player the trial gun
	var gun_instance : BaseGun = trial_gun.instantiate()
	player.add_child(gun_instance)

func _on_player_died() -> void:
	emit_signal("trial_completed", false)

func _on_timer_timeout() -> void:
	# Player survived the trial
	emit_signal("trial_completed", true)
