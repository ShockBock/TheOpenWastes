extends Node

## Stores projectile information for the player pistol.
## Referred to by ProjectileSpawner,
## so its script can be kept generic and 'weapon agnostic'

@export_group("Projectile characteristics")
@export_range(0, 20) var projectile_max_damage: float = 20.0
@export_range(0, 5) var projectile_life_secs: float = 2.0
@export var projectile_speed: float = 1.0

@export_group("Muzzle flash characteristics")
@export var spark_generation_probability: float = 0.2
@export var muzzle_flash_duration_secs: float = 0.2
@export var main_flash_scale_factor: float = 0.5
