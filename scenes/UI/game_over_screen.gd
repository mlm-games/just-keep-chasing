extends Control

func _ready() -> void:
	%RetryButton.grab_focus()
	%RetryButton.pressed.connect(_on_retry_button_pressed)
	
	var stats_text := ""
	stats_text += "Time: %02d:%02d\n" % [RunData.elapsed_time / 60, RunData.elapsed_time % 60]
	stats_text += "Mito Energy: %s\n" % RunData.mito_energy
	stats_text += "Enemies Killed: %s\n" % CountStats.get_stat(C.COUNT_STAT_KEYS.enemies_killed)
	stats_text += "Damage Dealt: %s\n" % int(CountStats.get_stat(C.COUNT_STAT_KEYS.damage_dealt))
	stats_text += "Games Played: %s\n" % CountStats.get_stat(C.COUNT_STAT_KEYS.games_played)
	stats_text += "Games Won: %s\n" % CountStats.get_stat(C.COUNT_STAT_KEYS.games_won)
	stats_text += "Powerups Used: %s\n" % CountStats.get_stat(C.COUNT_STAT_KEYS.powerups_used)
	%StatsLabel.text = stats_text

func _on_retry_button_pressed() -> void:
	UIManager.pop_all_layers()
	ScreenTransitions.change_scene_with_transition(C.SCREENS.WORLD)
