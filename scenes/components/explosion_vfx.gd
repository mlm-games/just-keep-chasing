class_name ExplosionVFX extends GPUParticles2D

var aoe_data : AreaOfEffectAttack

func _ready():
	amount = 32
	speed_scale = 1.5
	explosiveness = 1.0
	one_shot = true
	scale = Vector2.ONE * (aoe_data.radius / 64.0) if aoe_data else Vector2.ONE
	
	emitting = true
	animate_explosion()


func animate_explosion():
	var tween = create_tween()
	tween.tween_method(
		func(value): set_instance_shader_parameter("ring_width", value),
		0.5,
		0.0,
		lifetime
	)
	tween.tween_callback(queue_free)
