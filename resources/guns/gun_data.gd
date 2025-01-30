class_name GunData extends Resource

@export var unlocked: bool = false

@export var weapon_name_id: String
@export var sprite: Texture2D
@export var bullet: ProjectileData
@export var reload_time: float
@export var max_ammo: int
@export var ammo: int = max_ammo
@export var targeting_range: float
@export var fire_rate: float
@export var fire_audio: AudioStreamWAV
@export var damage_dropoff_curve: Curve
@export var speed_dropoff_curve: Curve

# Sprite properties
@export var sprite_scale: Vector2 = Vector2(0.08, 0.08)
@export var sprite_position: Vector2
@export var sprite_rotation_degrees: float
@export var sprite_flip_h: bool
@export var sprite_modulate: Color = Color.WHITE

# Bullet spawn point properties
@export var bullet_spawn_offset: Vector2

# Animation properties
@export var fire_animation_skew: float = (-0.0523599 + 5) # Default skew value from machine gun
@export var fire_animation_duration: float = fire_rate

@export var screen_shake_frequency : float = 10
@export var screen_shake_amplitude : float = 0.5
