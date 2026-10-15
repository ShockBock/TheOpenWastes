extends State

## For choose_animation_facing() (experimental): animation and horizontal flip
## for each 45-degree sector of the angle between the target-to-NPC direction
## and the NPC's movement, starting with the sector centred on 0 degrees.
const FACING_ANIMATIONS: Array[Array] = [
	["move_back", false],
	["move_back_side", false],
	["move_side", false],
	["move_forward_side", false],
	["move_forward", false],
	["move_forward_side", true],
	["move_side", true],
	["move_back_side", true],
]

@export var pursue_state: State

var character_idle_target_position: Vector3
var direction_to_idle_target: Vector3
var idle_behaviour_time_secs: float


func enter() -> void:
	super()
	idle_behaviour_time_secs = npc.stats.idle_behaviour_time_secs
	set_idle_target_position()


func process_physics(delta: float) -> State:
	if npc.global_position.distance_to(npc.target.global_position) <= npc.stats.minimum_idle_range:
		return pursue_state

	if idle_behaviour_time_secs <= 0:
		set_idle_target_position()
		idle_behaviour_time_secs = npc.stats.idle_behaviour_time_secs

	idle_behaviour_time_secs -= delta

	if npc.global_position.distance_to(character_idle_target_position) >= 0.05:
		move_to_idle_target_position(delta)

	return null


func set_idle_target_position() -> void:
	character_idle_target_position.x = (
		npc.global_position.x
		+ randf_range(-npc.stats.idle_movement_distance, npc.stats.idle_movement_distance)
	)
	character_idle_target_position.y = npc.global_position.y
	character_idle_target_position.z = (
		npc.global_position.z
		+ randf_range(-npc.stats.idle_movement_distance, npc.stats.idle_movement_distance)
	)


func move_to_idle_target_position(delta: float) -> void:
	direction_to_idle_target = (character_idle_target_position - npc.global_position).normalized()
	npc.move_horizontally(direction_to_idle_target, npc.stats.move_speed, delta)


#region Experimental
## Unfinished attempt to make the monk's animation match the direction it is
## moving while idle. Not yet connected to the rest of the code.
func choose_animation_facing() -> void:
	var direction_to_character: Vector3 = (
		(npc.global_position - npc.target.global_position).normalized()
	)
	var angle: float = rad_to_deg(direction_to_character.angle_to(direction_to_idle_target))
	var sector: int = int(fposmod(angle + 22.5, 360.0) / 45.0)
	animation_name = FACING_ANIMATIONS[sector][0]
	npc.animations.flip_h = FACING_ANIMATIONS[sector][1]
	npc.animations.play(animation_name)
#endregion
