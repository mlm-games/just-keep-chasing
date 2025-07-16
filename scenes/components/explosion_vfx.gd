class_name ExplosionVFX extends GPUParticles2D

var aoe_data : AreaOfEffectAttack

func _ready():
	emitting = true
	await A.tree.create_timer(lifetime).timeout
	queue_free()
	
	texture = preload("uid://dcvutra05kbxb")
	
	texture.width = aoe_data.radius
	texture.height = aoe_data.radius
	
	process_material = preload("uid://b8q57k4usxgac")
	
	speed_scale = 1.5
	explosiveness = 1.0
	one_shot = true
	
	animate_explosion()
	


func animate_explosion():
	var tween = create_tween()
	tween.tween_method(
		func(value): set_instance_shader_parameter("ring_width", value),
		0.5,
		0.0,
		lifetime
	)
	#tween.tween_callback(queue_free)
