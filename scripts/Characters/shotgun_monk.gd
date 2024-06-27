extends CharacterBody3D

@onready
var animations : AnimatedSprite3D = %Shotgun_monk_animations

@export_range(0, 2) var aiming_time_secs : float = 1
@export_range(0, 20) var firing_range : float = 20
@export_range(0, 1) var firing_time_secs : float = 0.5
@export_range(0, 4) var move_speed : float = 1
@export_range(0, 5) var random_move_time_secs : float = 3
@export_range(0, 5) var idle_wait_time_secs : float = 3
@export_range(0, 3) var idle_movement_distance : float = 1.5

@onready
var state_machine : Node = %State_machine

func _ready() -> void:
	state_machine.init(self, animations)

func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)

func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)

func _process(delta: float) -> void:
	state_machine.process_frame(delta)
