class_name GunData extends Resource

@export var bullet: Projectiles
@export var reload_time: float
@export var max_ammo: int
@export var ammo: int = max_ammo
@export var targeting_range: float
@export var fire_rate: float
@export var fire_audio: AudioStreamWAV
@export var damage_dropoff_curve: Curve
@export var speed_dropoff_curve: Curve
