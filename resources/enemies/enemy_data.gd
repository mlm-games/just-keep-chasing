class_name EnemyData extends BaseCharacterData

@export var base_enemy_scene : PackedScene

@export var base_contact_damage : float = 0
@export var enemy_knockback: float = 0.0

@export var mito_energy_value : int
@export var enemy_spawn_chance : float = 1
@export var enemy_spawn_order : int = 1

@export_group("Character Properties", "character_")
@export var character_hitbox_shape_type : Shape2D = RectangleShape2D.new()
@export var character_hitbox_shape_value : Vector2 = Vector2(44, 40)
@export var character_scale : Vector2 = Vector2.ONE

@export_group("Sprite Properies", "sprite_")
@export var sprite_texture : Texture2D
@export var sprite_scale : Vector2 = Vector2.ONE
@export var sprite_color : Color = Color.WHITE

@export var gun: GunData 
