extends State

@export
var fall_state: State

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

func process_physics(_delta: float) -> State:
	move_outside_navmesh()
	if !parent.is_on_floor():
		return fall_state
	return null

func move_outside_navmesh() -> void:
	var direction := player.global_position - parent.global_position
	direction = direction.normalized()

	parent.look_at(parent.global_position + direction, Vector3.UP)

	var velocity = direction * parent.move_speed
	parent.velocity = velocity
	parent.move_and_slide()  # This will move the character
