class_name State extends Node

signal transitioned(state: State, new_state_name: String)

func Enter():
	pass

func Exit():
	pass

func state_process(_delta: float):
	pass

func state_physics_process(_delta: float):
	pass
