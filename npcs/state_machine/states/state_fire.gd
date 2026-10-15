extends State

signal spawn_projectiles

@export var strafe_state: State
@export var pursue_state: State
@export var fire_sound: AudioStreamPlayer3D

var firing_time_countdown: float
var shot_blocked: bool = false

## Raises the line-of-sight ray so it does not collide with the ground
var raycast_vertical_offset: float = 0.5


func enter() -> void:
	super()
	firing_time_countdown = npc.stats.firing_time_secs
	shot_blocked = false
	# Fires if the target is in line of sight, otherwise sets shot_blocked
	# so that process_physics changes state.
	raycast_check_if_target_blocked()


func process_physics(delta: float) -> State:
	if shot_blocked or firing_time_countdown <= 0:
		if randi() % 2 == 0:
			return strafe_state
		return pursue_state

	firing_time_countdown -= delta
	return null


func raycast_check_if_target_blocked() -> void:
	var space_state: PhysicsDirectSpaceState3D = npc.get_world_3d().direct_space_state
	var params: PhysicsRayQueryParameters3D = (
		PhysicsRayQueryParameters3D
		. create(
			npc.global_position + Vector3.UP * raycast_vertical_offset,
			npc.target.global_position + Vector3.UP * raycast_vertical_offset,
		)
	)
	params.exclude = [npc.get_rid()]

	var hit: Dictionary = space_state.intersect_ray(params)
	if hit.get("collider") == npc.target:
		fire_weapon()
	else:
		shot_blocked = true


func fire_weapon() -> void:
	fire_sound.play()
	spawn_projectiles.emit()
