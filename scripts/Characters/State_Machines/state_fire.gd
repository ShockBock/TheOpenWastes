extends State

signal spawn_projectiles

@export var strafe_state : State
@export var pursue_state : State

@export var fire_sound : AudioStreamPlayer3D

@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

var firing_time_countdown : float
var shot_blocked : bool = false

# Stops raycast from colliding with the ground
var raycast_vertical_offset : float = 0.5

func enter() :
	super()
	firing_time_countdown = parent.firing_time_secs
	raycast_check_if_target_blocked()
	if shot_blocked :
		return strafe_state
	else :
		fire_weapon()


func process_physics(delta : float) -> State :
	if shot_blocked or firing_time_countdown <= 0 :
		var flip_a_coin = randi()
		if flip_a_coin % 2 == 0 :
			return strafe_state
		else :
			return pursue_state
	else :
		firing_time_countdown -= delta
		return null


func raycast_check_if_target_blocked() -> void :
	# Get access to Godot's space / physics wonders
	var space_state = get_world_3d().get_direct_space_state()
	
	# Set up raycast from character to player
	var params = PhysicsRayQueryParameters3D.new()
	
	var ray_from : Vector3 = parent.global_position
	ray_from.y += raycast_vertical_offset
	params.from = ray_from
	
	var ray_to : Vector3 = player.global_position
	ray_to.y += raycast_vertical_offset
	params.to = ray_to
	
	params.exclude = []
	
	# Fire the ray!
	var raycast = space_state.intersect_ray(params)
	if raycast.has("collider") and raycast.collider == player:
		fire_weapon()
	else:
		shot_blocked = true


func fire_weapon() -> void :
	fire_sound.play()
	emit_signal("spawn_projectiles")
