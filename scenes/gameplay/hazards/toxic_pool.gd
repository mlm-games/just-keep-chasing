class_name ToxicPool extends Area2D

@export var damage_per_tick: float = 5.0
@export var lifetime: float = 4.0
@export var tick_interval: float = 0.5

@onready var lifetime_timer: Timer = $LifetimeTimer
@onready var damage_tick_timer: Timer = $DamageTickTimer

var bodies_in_area: Array[Node2D] = []

func _ready() -> void:
	# Configure and start lifetime timer
	lifetime_timer.wait_time = lifetime
	lifetime_timer.one_shot = true
	lifetime_timer.timeout.connect(queue_free)
	lifetime_timer.start()

	# Configure damage tick timer
	damage_tick_timer.wait_time = tick_interval
	damage_tick_timer.timeout.connect(_on_damage_tick)
	
	# Connect area signals
	area_entered.connect(_on_area_entered)
	area_exited.connect(_on_area_exited)
	
	# Fade-in/out effect
	var tween = create_tween()
	modulate.a = 0.0
	tween.tween_property(self, "modulate:a", 1.0, 0.5)
	tween.chain().tween_property(self, "modulate:a", 0.0, 0.5).set_delay(lifetime - 0.5)


func _on_area_entered(area: Area2D) -> void:
	if area.owner is Player and not bodies_in_area.has(area.owner):
		bodies_in_area.append(area.owner)
		if bodies_in_area.size() == 1:
			damage_tick_timer.start()
			_on_damage_tick() # Damage immediately on enter

func _on_area_exited(area: Area2D) -> void:
	if area.owner is Player and bodies_in_area.has(area.owner):
		bodies_in_area.erase(area.owner)
		if bodies_in_area.is_empty():
			damage_tick_timer.stop()

func _on_damage_tick() -> void:
	var attack = Attack.new()
	attack.attack_damage = damage_per_tick
	
	for body in bodies_in_area:
		if is_instance_valid(body) and body.has_node("HitboxComponent"):
			body.get_node("HitboxComponent").damage(attack)
