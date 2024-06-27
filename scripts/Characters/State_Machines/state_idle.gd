extends State

@export var animation : AnimatedSprite3D

@onready var player : CharacterBody3D = \
get_tree().get_first_node_in_group("player")

var self_current_position : Vector3
var self_idle_target_position : Vector3
var player_self_angle : float

var idle_countdown : float

func enter() -> void:
	super()
	idle_countdown = parent.idle_wait_time_secs
	set_idle_target_position()
	
func process_physics(delta: float):
	#choose_animation_facing()
	if parent.global_position.distance_to(self_idle_target_position) < 0.05 \
	and idle_countdown > 0:
		idle_countdown -= delta
		return
	if parent.global_position.distance_to(self_idle_target_position) < 0.05 \
	and idle_countdown <= 0:
		idle_countdown = parent.idle_wait_time_secs
		set_idle_target_position()
		return
	move_to_idle_target_position(delta)


func set_idle_target_position() -> void:
	print ("parent.global_position = ", parent.global_position)
	self_idle_target_position.x = \
	parent.global_position.x + randf_range(-parent.idle_movement_distance, parent.idle_movement_distance)
	self_idle_target_position.z = \
	parent.global_position.z + randf_range(-parent.idle_movement_distance, parent.idle_movement_distance)
	print ("new set_idle_target_position = ", self_idle_target_position)

func check_if_idle_target_is_obstructed() -> void:
	pass

func move_to_idle_target_position(delta) -> void:
	var direction := self_idle_target_position - parent.global_position
	direction = direction.normalized()
	
	parent.look_at(parent.global_position + self_idle_target_position, Vector3.UP)
	
	var velocity = self_idle_target_position * parent.move_speed
	if parent.is_on_floor() == false:
		velocity.y -= gravity * delta
	parent.velocity = velocity
	parent.move_and_slide()  # This will move the character

func choose_animation_facing():
	# Calculate the direction vector from the player to the character
	var direction_to_character : Vector3 = \
	(self_current_position - player.global_position).normalized()
	
	# Calculate the direction vector from the character's current position 
	# to the target position
	var direction_to_target : Vector3 = \
	(self_idle_target_position - self_current_position).normalized()
	
	# Calculate the angle between these two direction vectors
	player_self_angle = rad_to_deg(direction_to_character.angle_to(direction_to_target))

