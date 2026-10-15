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
		move_outside_navmesh(delta)
		return null

	if distance_to_target > npc.stats.minimum_idle_range:
		return idle_state

	move_outside_navmesh(delta)
	return null


func move_outside_navmesh(delta: float) -> void:
	current_pursue_time_secs -= delta

	var direction: Vector3 = (npc.target.global_position - npc.global_position).normalized()

	var velocity: Vector3 = direction * npc.stats.move_speed
	velocity.y = 0 - (gravity * delta)

	npc.velocity = velocity
	npc.move_and_slide()

	npc.look_at(npc.global_position + direction, Vector3.UP)
