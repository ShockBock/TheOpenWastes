extends CharacterBody3D

@export var animations: AnimatedSprite3D
@export var state_machine: Node

#region Export variables
@export_group("Health")
@export var health: float = 100.0
## How long, as a function of how much damaged received,
## hit state should last.
@export var hit_state_length: float = 2
var last_damage_taken: float

@export_group("Attack")
## How long character takes aim before firing
@export_range(0, 2) var aiming_time_secs: float = 1.0
## Maximum distance in metres to player at which character takes aim
@export_range(0, 20) var firing_range: float = 20
## Time in seconds for which firing (i.e. muzzle-flash) animation plays
@export_range(0, 1) var firing_time_secs: float = 0.5

@export_group("Movement")
## Rate at which character moves. Used in multiple animations
@export_range(0, 4) var move_speed: float = 1.0
## Time in seconds character will strafe
@export_range(0, 3) var strafe_time_secs: float = 1.5

@export_group("Pursuit")
## Time character will continue to pursue player, even within firing range,
## before switching to aiming and firing states
@export_range(0, 5) var minimum_pursue_time_secs: float = 2.5

@export_group("Idling")
## Time in seconds character should spend on moving to random position
## and loitering at a reached random position
@export_range(0, 5) var idle_behaviour_time_secs: float = 3.0
## Maximum distance in metres idling character moves from current position
@export_range(0, 3) var idle_movement_distance: float = 1.5
## Minimum range in metres from player at which character enters idling state
@export var minimum_idle_range: float = 40

@export_group("Firing")
## Max damage per projectile. Ideally should attenuate with range
@export_range(0, 20) var projectile_max_damage: float = 20
## How inaccurate the character is when firing at a target
@export_range(0, 1) var inaccuracy: float = 0.5
## How many pellets the shotgun fires, per cartridge
@export var projectiles: int = 6
## Vertical offset on target to improve aim
@export_range(-2, 2) var target_y_offset_metres: float = 1
## How much buckshot from shotgun spreads
@export_range(0, 1) var projectile_spread: float = 0.5
## Speed of each projectile
@export var projectile_speed: float = 1.0
## Time (secs) until projectile deletes itself, if not having collided with anything
@export_range(0, 5) var projectile_life_secs: float = 2
## x-offset of projectile spawn point, local to firing character
@export_subgroup("Offsets")
@export_range(-1, 1) var projectile_spawn_x_offset: float = 0.0
## y-offset of projectile spawn point, local to firing character
@export_range(0, 2) var projectile_spawn_y_offset: float = 1.0
## z-offset of projectile spawn point, local to firing character
@export_range(-1, 1) var projectile_spawn_z_offset: float = 0.0

#endregion

## Referred to by state machine branches to determine whether collision mesh
## has already been turned off
var is_dead: bool = false

func _ready() -> void:
	state_machine.init(self, animations)


func taken_hit(damage: float) -> void:
	last_damage_taken = damage
	state_machine.taken_hit()


func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)


func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)


func _process(delta: float) -> void:
	state_machine.process_frame(delta)
