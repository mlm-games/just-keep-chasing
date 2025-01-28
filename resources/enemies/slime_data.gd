class_name EnemyData extends BaseCharacterData

@export var base_enemy_scene : PackedScene

@export var base_contact_damage : float = 0
@export var research_point_value : int = NAN

@export_group("Character Properties", "character_")
@export var character_hitbox_shape_type : Shape2D = RectangleShape2D.new()
@export var character_hitbox_shape_value : Vector2
@export var character_scale : Vector2 = Vector2.ONE

@export_group("Sprite Properies", "sprite_")
@export var sprite_texture : Texture2D
@export var sprite_scale : Vector2
@export var sprite_color : Color = Color.WHITE
