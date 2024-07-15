extends State

@export var aim_state: State
@export var idle_state: State

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")

var current_pursue_time_secs: float

func enter() -> void:
	super()
	current_pursue_time_secs = NPC.minimum_pursue_time_secs


func process_physics(delta: float) -> State:
	
	var distance_to_player: float = \
			NPC.global_position.distance_to(player.global_position)
	
	if distance_to_player < NPC.firing_range:
		if current_pursue_time_secs <= 0:
			return aim_state
		else:
			move_outside_navmesh(delta)
			return null
	
	if distance_to_player > NPC.minimum_idle_range:
		return idle_state
	
	else:
		move_outside_navmesh(delta)
		return null

func move_outside_navmesh(delta) -> void:
	current_pursue_time_secs -= delta
	
	var direction:= player.global_position - NPC.global_position
	direction = direction.normalized()

	NPC.look_at(NPC.global_position + direction, Vector3.UP)

	var velocity = direction * NPC.move_speed
	
	if not NPC.is_on_floor():
		velocity.y = 0 - (gravity * delta)
	
	else:
		velocity.y = 0
	
	NPC.velocity = velocity
	NPC.move_and_slide()  # This will move the character
