extends State

@onready var animation : AnimatedSprite3D = %Shotgun_monk_animations

@onready var player : CharacterBody3D = \
get_tree().get_first_node_in_group("player")

var character_current_position : Vector3
var character_idle_target_position : Vector3
var player_character_angle : float
var direction_to_idle_target : Vector3

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
	direction_to_idle_target = character_idle_target_position - parent.global_position
	# Normalize the direction to get a unit vector
	direction_to_idle_target = direction_to_idle_target.normalized()
	
	if not parent.is_on_floor():
		direction_to_idle_target.y -= gravity * delta
	else:
		direction_to_idle_target.y = 0
	
	parent.velocity = direction_to_idle_target * parent.move_speed
	parent.move_and_slide()
	
	
func choose_animation_facing():
	var angle_between_player_and_character_facing : float
	angle_between_player_and_character_facing = \
			rad_to_deg(player.global_position.angle_to(direction_to_idle_target))
	# Calculate the direction vector from the player to the character:
	
	var direction_to_character = (parent.global_position - player.global_position).normalized()

	angle_between_player_and_character_facing = rad_to_deg(direction_to_character.angle_to(direction_to_idle_target))

	if angle_between_player_and_character_facing < 0:
		angle_between_player_and_character_facing += 360  # Normalize the angle to be between 0 and 360 degrees

	if angle_between_player_and_character_facing < 22.5 \
			or angle_between_player_and_character_facing >= 337.5:
		animation_name = "move_back"
		animations.flip_h = false
		animations.play(animation_name)
		print ("PC-NPC angle = ", angle_between_player_and_character_facing, " ", animation_name)
		return
	elif angle_between_player_and_character_facing < 67.5:
		animation_name = "move_back_side"
		animations.flip_h = false
		animations.play(animation_name)
		print ("PC-NPC angle = ", angle_between_player_and_character_facing, " ", animation_name)
		return
	elif angle_between_player_and_character_facing < 112.5:
		animation_name = "move_side"
		animations.flip_h = false
		animations.play(animation_name)
		print ("PC-NPC angle = ", angle_between_player_and_character_facing, " ", animation_name)
		return
	elif angle_between_player_and_character_facing < 157.5:
		animation_name = "move_forward_side"
		animations.flip_h = false
		animations.play(animation_name)
		print ("PC-NPC angle = ", angle_between_player_and_character_facing, " ", animation_name)
		return
	elif angle_between_player_and_character_facing < 202.5:
		animation_name = "move_forward"
		animations.flip_h = false
		animations.play(animation_name)
		print ("PC-NPC angle = ", angle_between_player_and_character_facing, " ", animation_name)
		return
	elif angle_between_player_and_character_facing < 247.5:
		animation_name = "move_forward_side"
		animations.flip_h = true
		animations.play(animation_name)
		print ("PC-NPC angle = ", angle_between_player_and_character_facing, " ", animation_name, " flipped")

		return
	elif angle_between_player_and_character_facing < 292.5:
		animation_name = "move_side"
		animations.flip_h = true
		animations.play(animation_name)
		print ("PC-NPC angle = ", angle_between_player_and_character_facing, " ", animation_name, " flipped")
		return
	else:
		animation_name = "move_back_side"
		animations.flip_h = true
		animations.play(animation_name)
		print ("PC-NPC angle = ", angle_between_player_and_character_facing, " ", animation_name, " flipped")
		return
