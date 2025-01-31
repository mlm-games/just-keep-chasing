class_name ProjectileData extends Resource

@export_group("Stats", "projectile_")
@export var projectile_speed : float = 750
@export var projectile_range : int = 1000
@export var projectile_damage : float = -1
@export var projectile_spread : float = 0

@export_group("Sprite Properties", "sprite_")
@export var sprite_scale : Vector2 = Vector2(0.06, 0.17)
@export var sprite_modulate : Color = Color.WHITE
@export var sprite_texture : Texture2D
@export var sprite_rotation : float = 0
@export var sprite_offset : Vector2 = Vector2.ZERO

@export var collision_shape_radius : float = 9.0
@export var collision_shape_mask: int = 3
