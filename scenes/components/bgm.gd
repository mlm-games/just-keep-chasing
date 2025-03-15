class_name BGMPlayer extends AudioStreamPlayer

#const BGMPlayerScene = preload("uid://bsnsoth73s5n1")

func _ready() -> void:
	bus = "Music"

func fade_in_bgm() -> void:
	var tween := create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_LINEAR)
	var initial_vol := volume_db
	volume_db = -80
	tween.tween_property(self, "volume_db", initial_vol, 1.0)
	play()
