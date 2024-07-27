extends Node

## Stores projectile information for the player pistol.
## Referred to by ProjectileSpawner,
## so its script can be kept generic and 'weapon agnostic'

@export_range(0, 20) var projectile_max_damage: float = 20.0
@export_range(0, 5) var projectile_life_secs: float = 2.0
@export var projectile_speed: float = 1.0
