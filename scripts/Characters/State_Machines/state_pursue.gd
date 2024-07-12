extends State

@export var aim_state : State
@export var idle_state : State

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

var current_pursue_time_secs : float

func enter() -> void :
	super()
	current_pursue_time_secs = parent.minimum_pursue_time_secs


func process_physics(delta : float) -> State :
	
	var distance_to_player : float = \
			parent.global_position.distance_to(player.global_position)
	
	#if not parent.is_on_floor() :
		#return fall_state
	
	if distance_to_player < parent.firing_range :
		if current_pursue_time_secs <= 0 :
			return aim_state
		else :
			move_outside_navmesh(delta)
			return null
	
	if distance_to_player > parent.minimum_idle_range :
		return idle_state
	
	else :
		move_outside_navmesh(delta)
		return null

func move_outside_navmesh(delta) -> void :
	current_pursue_time_secs -= delta
	
	var direction := player.global_position - parent.global_position
	direction = direction.normalized()

	parent.look_at(parent.global_position + direction, Vector3.UP)

	var velocity = direction * parent.move_speed
	
	if not parent.is_on_floor() :
		velocity.y = 0 - (gravity * delta)
	
	else :
		velocity.y = 0
	
	parent.velocity = velocity
	parent.move_and_slide()  # This will move the character
