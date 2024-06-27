extends State

@export var random_move_state: State
@export var aim_state: State

@export var fire_sound : AudioStreamPlayer3D

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

var firing_time_countdown : float


func enter():
	super()
	fire_sound.play()
	firing_time_countdown = parent.firing_time_secs

func process_physics(delta: float) -> State:
	if firing_time_countdown <= 0:
		return random_move_state
	
	firing_time_countdown -= delta
	return null

func exit():
	firing_time_countdown = parent.firing_time_secs
