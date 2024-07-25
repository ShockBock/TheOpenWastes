extends State

@export var pursue_state: State
@export var aim_state: State

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")

var random_move_time_secs_countdown: float
var distance_to_player: float

var random_x_distance_metres: float
var random_z_distance_metres: float
var random_move_vector: Vector3
var direction: Vector3

var character_to_player_vector: Vector3
var strafing_target_a: Vector3
var strafing_target_b: Vector3
var strafing_target_final: Vector3
@export var strafing_target_amplification_factor: float = 10

func enter():
	super()
	random_move_time_secs_countdown = NPC.strafe_time_secs
	distance_to_player = NPC.global_position.distance_to(player.global_position)
	calculate_strafing_target()

func calculate_strafing_target():
	# Works out direction for character to move
	# perpendicular to a line between it and the player
	
	# Calculate direction vector
	character_to_player_vector = NPC.global_position - player.global_position
	
	# Project this vector onto the x-z plane
	character_to_player_vector.y = 0
	
	# Normalise it
	character_to_player_vector = character_to_player_vector.normalized()
	
	# Calculate two strafing targets as both perpendicular to the above
	# ApNPCly the dot product concept explains why (if!) this works
	strafing_target_a.x = -character_to_player_vector.z
	strafing_target_a.z = character_to_player_vector.x
	
	strafing_target_b.x = character_to_player_vector.z
	strafing_target_b.z = -character_to_player_vector.x
	
	# Choose one of the two targets to which to move
	if randi() % 2 == 0:
		strafing_target_final = strafing_target_a

	else:
		strafing_target_final = strafing_target_b

func process_physics(delta: float) -> State:
	if random_move_time_secs_countdown <= 0:
		if distance_to_player > NPC.firing_range:
			return pursue_state
		else:
			return aim_state
	
	NPC.look_at(player.global_position, Vector3.UP)

	var velocity = strafing_target_final * NPC.move_speed
	
	if not NPC.is_on_floor():
		velocity.y = 0 - (gravity * delta)
	
	else:
		velocity.y = 0
		
	NPC.velocity = velocity
	NPC.move_and_slide()
	
	random_move_time_secs_countdown -= delta
	return null
