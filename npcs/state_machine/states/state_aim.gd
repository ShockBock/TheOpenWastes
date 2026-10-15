extends State

@export var pursue_state: State
@export var fire_state: State

var aiming_time_countdown: float


func enter() -> void:
	super()
	aiming_time_countdown = npc.stats.aiming_time_secs


func process_physics(delta: float) -> State:
	if aiming_time_countdown > 0:
		aiming_time_countdown -= delta
		return null

	var distance_to_target: float = npc.global_position.distance_to(npc.target.global_position)
	if distance_to_target > npc.stats.firing_range:
		return pursue_state
	return fire_state


func exit() -> void:
	aiming_time_countdown = npc.stats.aiming_time_secs
