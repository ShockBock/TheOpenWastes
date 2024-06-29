extends CharacterBody3D

@onready
var animations : AnimatedSprite3D = %Shotgun_monk_animations
@onready
var state_machine : Node = %State_machine

#region Export variables
## Set how long character takes aim before firing
@export_range(0, 2) var aiming_time_secs : float = 1

## Set maximum distance in metres to player at which character takes aim
@export_range(0, 20) var firing_range : float = 20

## Set time in seconds for which firing (i.e. muzzle-flash) animation plays
@export_range(0, 1) var firing_time_secs : float = 0.5

## Set rate at which character moves. Used in multiple animations
@export_range(0, 4) var move_speed : float = 1.0

## Set amount of time character will strafe
@export_range(0, 3) var strafe_time_secs: float = 1.5

## Idle: Set time in seconds character should spend on moving to random position
## and loitering at a reached random position
@export_range(0, 5) var idle_behaviour_time_secs : float = 3

## Idle: maximum distance in metres 
## idling character moves from current position
@export_range(0, 3) var idle_movement_distance : float = 1.5

## Minimum range in metres from player at which character enters idling state
@export var minimum_idle_range : float = 40
#endregion

func _ready() -> void:
	state_machine.init(self, animations)

func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)
