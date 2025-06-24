class_name NerveImpulse extends BaseEnemy
##Dummy enemy inheritance, acts like a bullet

@export var speed: float = 1000.0
@export var damage: float = 25.0

# This must be set by the spawner *before* adding to the scene tree.
var target_point: Vector2

@onready var damage_area: Area2D = $DamageArea

func _ready() -> void:
	# This enemy is fire-and-forget. It does not track.
	if target_point == Vector2.ZERO:
		push_warning("NerveImpulse spawned without a target_point. Will not move.")
		return
		
	velocity = global_position.direction_to(target_point) * speed
	rotation = velocity.angle()
	
	$VisibleOnScreenNotifier2D.screen_exited.connect(queue_free)
	damage_area.area_entered.connect(_on_damage_area_entered)

func _physics_process(delta: float) -> void:
	move_and_slide()

func _on_damage_area_entered(area: Area2D):
	if area is HitboxComponent and area.owner is Player:
		var attack = Attack.new()
		attack.attack_damage = damage
		area.damage(attack)
		
		# To prevent hitting the same player multiple times, we disable the damage area.
		# The projectile itself continues moving until it's off-screen.
		damage_area.get_child(0).set_deferred("disabled", true)
