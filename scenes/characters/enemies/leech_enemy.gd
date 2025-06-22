class_name LeechEnemy extends BaseMeleeEnemy

@onready var state_chart = $StateChart
@onready var lifesteal_component = $LifestealAiComponent

func _ready():
	super._ready()
	
	lifesteal_component.attached.connect(func(): state_chart.send_event("on_attached"))
	lifesteal_component.detached.connect(func(): state_chart.send_event("on_detached"))

func _physics_process(delta):
	super._physics_process(delta)
	
	if not health_component.is_dead():
		state_chart._physics_process(delta)
