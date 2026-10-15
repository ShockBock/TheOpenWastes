extends State

@export var aim_state: State
@export var idle_state: State

var current_pursue_time_secs: float


func enter() -> void:
	super()
	current_pursue_time_secs = npc.stats.minimum_pursue_time_secs


func process_physics(delta: float) -> State:
	var distance_to_target: float = npc.global_position.distance_to(npc.target.global_position)

	if distance_to_target < npc.stats.firing_range:
		if current_pursue_time_secs <= 0:
			return aim_state
		move_towards_target(delta)
		return null

	if distance_to_target > npc.stats.minimum_idle_range:
		return idle_state

	move_towards_target(delta)
	return null


func move_towards_target(delta: float) -> void:
	current_pursue_time_secs -= delta
	npc.move_towards(
		npc.target.global_position, npc.target.current_building, npc.stats.move_speed, delta
	)
