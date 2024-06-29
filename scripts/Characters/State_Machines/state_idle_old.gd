extends State

@export var animation : AnimatedSprite3D

@onready var player : CharacterBody3D = \
get_tree().get_first_node_in_group("player")

var character_current_position : Vector3
var character_idle_target_position : Vector3
var player_character_angle : float
var direction : Vector3

var idle_behaviour_time_secs: float

func enter() -> void:
	super()
	idle_behaviour_time_secs = parent.idle_behaviour_time_secs
	set_idle_target_position()
	
func process_physics(delta: float):
	choose_animation_facing()
	if idle_behaviour_time_secs <= 0:
		set_idle_target_position()
		idle_behaviour_time_secs = parent.idle_behaviour_time_secs
		
	if parent.global_position.distance_to(character_idle_target_position) < 0.05:
		idle_behaviour_time_secs -= delta
		return
	
	move_to_idle_target_position(delta)
	idle_behaviour_time_secs -= delta

func set_idle_target_position() -> void:
	character_idle_target_position.x = \
			parent.global_position.x + randf_range(-parent.idle_movement_distance,
			parent.idle_movement_distance)
	character_idle_target_position.y = parent.global_position.y
	character_idle_target_position.z = \
			parent.global_position.z + randf_range(-parent.idle_movement_distance,
			parent.idle_movement_distance)

func move_to_idle_target_position(delta) -> void:
	# Calculate the direction vector from the current position to the target position
	direction = character_idle_target_position - parent.global_position
	# Normalize the direction to get a unit vector
	direction = direction.normalized()
	
	if not parent.is_on_floor():
		direction.y -= gravity * delta
	else:
		direction.y = 0
	
	parent.velocity = direction * parent.move_speed
	parent.move_and_slide()
	
func choose_animation_facing():
	var angle_between_player_and_character_facing : float
	angle_between_player_and_character_facing = \
			rad_to_deg(player.global_position.angle_to(direction))
	print("angle_between_player_and_character_facing = ", angle_between_player_and_character_facing)

