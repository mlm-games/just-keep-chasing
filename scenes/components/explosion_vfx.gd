class_name ExplosionVFX extends GPUParticles2D

var aoe_data : AreaOfEffectAttack

func _ready():
	emitting = true
	await get_tree().create_timer(lifetime).timeout
	queue_free()
	
	texture = preload("uid://dcvutra05kbxb")
	
	texture.width = aoe_data.radius
	texture.height = aoe_data.radius
	
	process_material = preload("uid://b8q57k4usxgac")
	
	speed_scale = 1.5
	explosiveness = 1.0
	one_shot = true
