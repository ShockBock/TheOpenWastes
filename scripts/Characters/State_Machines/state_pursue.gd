extends State

@export var fall_state : State
@export var aim_state : State
@export var idle_state : State

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

var current_pursue_time_secs : float

func enter() -> void :
	super()
	current_pursue_time_secs = parent.minimum_pursue_time_secs


func process_physics(delta : float) -> State :
	var distance_to_player : float = parent.global_position.distance_to(player.global_position)
	
	if not parent.is_on_floor() :
		return fall_state
	
	if distance_to_player < parent.firing_range and current_pursue_time_secs <= 0:
		return aim_state
	
	if distance_to_player > parent.minimum_idle_range :
		return idle_state
	
	else :
		current_pursue_time_secs -= delta
		move_outside_navmesh()
		return null

func move_outside_navmesh() -> void :
	var direction := player.global_position - parent.global_position
	direction = direction.normalized()

	parent.look_at(parent.global_position + direction, Vector3.UP)

	var velocity = direction * parent.move_speed
	parent.velocity = velocity
	parent.move_and_slide()  # This will move the character
