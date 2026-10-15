extends State

@export var pursue_state: State
@export var aim_state: State

var strafe_time_countdown: float
var distance_to_target: float
var strafe_direction: Vector3


func enter() -> void:
	super()
	strafe_time_countdown = npc.stats.strafe_time_secs
	distance_to_target = npc.global_position.distance_to(npc.target.global_position)
	calculate_strafe_direction()


## Picks one of the two directions at right angles to the line between the
## NPC and its target, at random.
func calculate_strafe_direction() -> void:
	var to_target: Vector3 = npc.global_position - npc.target.global_position
	to_target.y = 0
	to_target = to_target.normalized()

	var perpendicular: Vector3 = Vector3(-to_target.z, 0, to_target.x)
	strafe_direction = perpendicular if randi() % 2 == 0 else -perpendicular


func process_physics(delta: float) -> State:
	if strafe_time_countdown <= 0:
		if distance_to_target > npc.stats.firing_range:
			return pursue_state
		return aim_state

	var velocity: Vector3 = strafe_direction * npc.stats.move_speed
	velocity.y = 0 - (gravity * delta)

	npc.velocity = velocity
	npc.move_and_slide()

	npc.look_at(npc.target.global_position, Vector3.UP)

	strafe_time_countdown -= delta
	return null
