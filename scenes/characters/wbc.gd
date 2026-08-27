extends CharacterBody2D

var velocity_component: VelocityComponent

func _ready() -> void:
	velocity_component = VelocityComponent.new()
	add_child(velocity_component)

func _physics_process(_delta: float) -> void:
	move_and_slide()
