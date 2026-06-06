class_name NerveImpulse extends BaseEnemy
##Dummy enemy inheritance, acts like a bullet

@export var speed: float = 1000.0
@export var damage: float = 25.0

# This must be set by the spawner *before* adding to the scene tree.
var target_point: Vector2

@onready var damage_area: Area2D = $DamageArea

func _ready() -> void:
	super._ready()

	velocity_component.set_physics_process(false)

	var target := target_point
	if target == Vector2.ZERO:
		var player := A.tree.get_first_node_in_group("Player")
		if not is_instance_valid(player):
			push_warning("NerveImpulse: No target_point and no player found. Disabling.")
			set_physics_process(false)
			return
		target = player.global_position

	velocity = global_position.direction_to(target) * speed
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
