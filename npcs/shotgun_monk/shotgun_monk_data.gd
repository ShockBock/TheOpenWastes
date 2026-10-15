extends Node
@export_group("Health")
@export_range(10.0, 300.0) var health: float = 100.0
## How long, as a function of how much damaged received,
## hit state should last.
@export_range(0.5, 3.0) var hit_state_length: float = 1.0

@export_group("Attack")
## How long character takes aim before firing
@export_range(0.0, 2.0) var aiming_time_secs: float = 1.0
## Maximum distance in metres to player at which character takes aim
@export_range(0.0, 20.0) var firing_range: float = 20.0
## Time in seconds for which firing (i.e. muzzle-flash) animation plays
@export_range(0.0, 1.0) var firing_time_secs: float = 0.5

@export_group("Movement")
## Rate at which character moves. Used in multiple animations
@export_range(0.0, 4.0) var move_speed: float = 1.0
## Time in seconds character will strafe
@export_range(0.0, 3.0) var strafe_time_secs: float = 1.5

@export_group("Pursuit")
## Time character will continue to pursue player, even within firing range,
## before switching to aiming and firing states
@export_range(0.0, 5.0) var minimum_pursue_time_secs: float = 2.5

@export_group("Idling")
## Time in seconds character should spend on moving to random position
## and loitering at a reached random position
@export_range(0.0, 5.0) var idle_behaviour_time_secs: float = 3.0
## Maximum distance in metres idling character moves from current position
@export_range(0.0, 3.0) var idle_movement_distance: float = 1.5
## Minimum range in metres from player at which character enters idling state
@export_range(20.0, 60.0) var minimum_idle_range: float = 40.0

@export_group("Firing")
## Max damage per projectile. Ideally should attenuate with range
@export_range(0.0, 20.0) var projectile_max_damage: float = 20.0
## How many pellets the shotgun fires, per cartridge
@export var projectiles: int = 6
## Vertical offset of firing target relative to player's local origin
@export_range(-2.0, 2.0) var target_y_offset_metres: float = 1.0
## How much buckshot from shotgun spreads
@export_range(0.0, 1.0) var projectile_spread: float = 0.1
## Speed of each projectile
@export_range(10.0, 100.0) var projectile_speed: float = 1.0
## Time (secs) until projectile deletes itself, if not having collided with anything
@export_range(0.0, 5.0) var projectile_life_secs: float = 2.0
## x-offset of projectile spawn point, local to firing character
