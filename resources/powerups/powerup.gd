class_name PowerupData extends Resource

@export var id : String
@export var icon : Texture2D
@export var icon_modulate : Color = Color.WHITE
@export var icon_scale : Vector2 = Vector2(0.3, 0.3)
@export var spawn_chance_percent : float = NAN
@export var powerup_type : GameState.PowerupType
