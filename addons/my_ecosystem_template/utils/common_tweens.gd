class_name CommonTweens

static func set_tweened_value(node: Node, property: NodePath, val: Variant, dur: float = 0.1):
	var tween : Tween =  Engine.get_main_loop().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC).set_ignore_time_scale().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(node, property, val, dur)
