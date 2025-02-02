class_name StatModifier extends Resource

@export var value : float = 0
@export var key: GameStats.Stats
@export var operation: GameStats.Operation
@export var duration: float = 0.0  # 0 means permanent
#@export_enum("ADD","MULTIPLY","REPLACE","EXPONENTIAL") var operation : int
