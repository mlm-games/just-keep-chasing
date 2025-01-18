class_name StatsModifier extends Resource

@export var value : float = 0
@export var key: GameState.Stats
@export var operation: GameState.Operation
#@export_enum("ADD","MULTIPLY","REPLACE","EXPONENTIAL") var operation : int
