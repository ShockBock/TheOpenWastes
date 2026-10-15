class_name MinigunStats
extends WeaponStats

## Tuning values for the minigun, on top of the shared firearm values.

@export_group("Minigun characteristics")
@export_range(0.0, 100.0) var barrel_rotation_rate: float = 1.0
@export_range(0.0, 0.9) var barrel_spindown_factor: float = 0.5
## Shots per second
@export_range(1.0, 40.0) var fire_rate_factor: float = 20.0
