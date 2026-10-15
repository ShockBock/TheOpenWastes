class_name WeaponStats
extends Resource

## Tuning values for a firearm, shared by the projectile spawner and the
## muzzle flash so that both scripts stay weapon-agnostic.

@export_group("Projectile characteristics")
## Maximum damage per projectile; falls off over the projectile's lifetime
@export_range(0.0, 20.0) var projectile_max_damage: float = 20.0
## Time in seconds before an unobstructed projectile disappears
@export_range(0.0, 5.0) var projectile_life_secs: float = 2.0
## Projectile speed in metres per second
@export var projectile_speed: float = 1.0

@export_group("Muzzle flash characteristics")
@export_range(0.0, 1.0) var spark_generation_probability: float = 0.2
@export var muzzle_flash_duration_secs: float = 0.2
@export var main_flash_scale_factor: float = 0.5
