extends Node

var states : Dictionary = {}
var current_state : State

@export var initial_state : State

func _ready() -> void:
	for child in get_children()[0].get_children():
		if child is State:
			states[child.name.to_lower()] = child
			child.transitioned.connect(on_state_transition)
	
	if initial_state:
		initial_state.Enter()
		current_state = initial_state

func _process(delta: float) -> void:
	if current_state:
		current_state.state_process(delta)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.state_physics_process(delta)

func on_state_transition(state, new_state_name):
	if state != current_state:
		return
	
	var new_state = state.get(new_state_name.to_lower())
	if !new_state:
		return
	
	if current_state:
		return
	
	new_state.Enter()
	
	current_state = new_state

