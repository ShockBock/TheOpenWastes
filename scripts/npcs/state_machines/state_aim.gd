extends State

@export var pursue_state: State
@export var fire_state: State
@export var npc_data: Node

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")

var aiming_time_countdown: float

func enter():
	super()
	aiming_time_countdown = npc_data.aiming_time_secs


func process_physics(delta: float) -> State:
	var distance_to_player: float = npc.global_position.distance_to(player.global_position)
	if aiming_time_countdown > 0:
		aiming_time_countdown -= delta
		return null
	
	if distance_to_player > npc_data.firing_range:
		return pursue_state
	
	else:
		return fire_state


func exit():
	aiming_time_countdown = npc_data.aiming_time_secs
