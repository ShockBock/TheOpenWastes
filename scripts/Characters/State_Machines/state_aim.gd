extends State

@export var pursue_state: State
@export var fire_state: State

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

var aiming_time_countdown : float

func enter():
	super()
	aiming_time_countdown = parent.aiming_time_secs

func process_physics(delta: float) -> State:
	var distance_to_player : float = parent.global_position.distance_to(player.global_position)
	if  distance_to_player > parent.firing_range:
		return pursue_state
	
	if aiming_time_countdown <= 0:
		return fire_state
	
	aiming_time_countdown -= delta
	return null

func exit():
	aiming_time_countdown = parent.aiming_time_secs
