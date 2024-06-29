extends State

@export var fall_state : State
@export var aim_state : State
@export var fire_state : State
@export var idle_state : State

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

func process_physics(delta: float) -> State:
	
	#var distance_to_player : float = parent.global_position.distance_to(player.global_position)
	#if  distance_to_player < parent.firing_range:
		#return aim_state
	#
	#if distance_to_player > parent.minimum_idle_range:
		#return idle_state
	
	move_outside_navmesh(delta)
	return null

func move_outside_navmesh(delta) -> void:
	var direction := player.global_position - parent.global_position
	
	direction = direction.normalized()
	if not parent.is_on_floor():
		direction.y -= gravity * delta

	parent.look_at(parent.global_position + direction, Vector3.UP)

	var velocity = direction * parent.move_speed
	parent.velocity = velocity
	parent.move_and_slide()  # This will move the character
