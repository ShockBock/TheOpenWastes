class_name NPCStats
extends Resource

## Tuning values for an NPC. Saved as a .tres file and shared by every NPC
## that uses it, so it must only hold settings, never per-NPC state such as
## current health.

@export_group("Health")
@export_range(10.0, 300.0) var max_health: float = 100.0
## How long, in seconds, the NPC stays in its hit state after taking damage
@export_range(0.5, 3.0) var hit_state_length: float = 1.0

@export_group("Attack")
## How long the NPC takes aim before firing
@export_range(0.0, 2.0) var aiming_time_secs: float = 1.0
## Maximum distance in metres to the target at which the NPC takes aim
@export_range(0.0, 20.0) var firing_range: float = 20.0
## Time in seconds for which the firing (muzzle-flash) animation plays
@export_range(0.0, 1.0) var firing_time_secs: float = 0.5

@export_group("Movement")
## Speed in metres per second. Used by several states
@export_range(0.0, 4.0) var move_speed: float = 1.0
## Time in seconds the NPC will strafe
@export_range(0.0, 3.0) var strafe_time_secs: float = 1.5

@export_group("Pursuit")
## Time the NPC keeps pursuing the target, even within firing range,
## before switching to aiming and firing
@export_range(0.0, 5.0) var minimum_pursue_time_secs: float = 2.5

@export_group("Idling")
## Time in seconds spent moving to a random position and loitering there
@export_range(0.0, 5.0) var idle_behaviour_time_secs: float = 3.0
## Maximum distance in metres an idling NPC moves from its current position
@export_range(0.0, 3.0) var idle_movement_distance: float = 1.5
## Distance in metres from the target beyond which the NPC goes idle
@export_range(20.0, 60.0) var minimum_idle_range: float = 40.0

@export_group("Firing")
## Maximum damage per projectile; falls off over the projectile's lifetime
@export_range(0.0, 20.0) var projectile_max_damage: float = 20.0
## Projectiles fired per shot (e.g. pellets per shotgun cartridge)
@export var projectiles: int = 6
## Height of the aiming point relative to the target's origin; positive is
## lower
@export_range(-2.0, 2.0) var target_y_offset_metres: float = 1.0
## How far each projectile's direction may deviate from the aiming line
@export_range(0.0, 1.0) var projectile_spread: float = 0.1
## Projectile speed in metres per second
@export_range(10.0, 100.0) var projectile_speed: float = 1.0
## Time in seconds before an unobstructed projectile disappears
@export_range(0.0, 5.0) var projectile_life_secs: float = 2.0
