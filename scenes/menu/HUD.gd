extends CanvasLayer


var elapsed_time = 0

func _ready():
	$Timer.connect("timeout", _on_timer_timeout)

func _on_timer_timeout():
	elapsed_time += 1
	@warning_ignore("integer_division")
	var minutes = elapsed_time / 60
	var seconds = elapsed_time % 60
	%TimerLabel.text = "%02d:%02d" % [minutes, seconds]