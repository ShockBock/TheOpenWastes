class_name NPC
extends CharacterBody3D

## A non-player character whose behaviour is driven by an NPCStateMachine.
##
## Outdoors, NPCs move in straight lines. Inside buildings they follow the
## building's navigation mesh: to reach a target inside a building, an NPC
## first heads for that building's entrance; to leave one, it follows the
## navigation mesh back to its own building's entrance.

signal died

## How close an NPC must be to a building's entrance to switch to its
## navigation mesh
const ENTRANCE_REACHED_DISTANCE: float = 1.5
## How far a destination must move before the NPC asks for a new path
const REPATH_DISTANCE: float = 0.5
## How often, in seconds, the NPC asks for a new path regardless
const REPATH_INTERVAL_SECS: float = 1.0
## Horizontal distance at which a path corner counts as reached
const PATH_POINT_REACHED_DISTANCE: float = 0.3

@export var stats: NPCStats
@export var animations: AnimatedSprite3D
@export var state_machine: NPCStateMachine

var health: float
var last_damage_taken: float = 0.0
var is_dead: bool = false
## What the NPC hunts: currently always the player
var target: Node3D
## The building the NPC is inside, set by the building; null when outdoors
var current_building: Node3D
var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var _path: PackedVector3Array = []
var _path_index: int = 0
var _path_destination: Vector3 = Vector3.INF
var _path_age_secs: float = 0.0


func _ready() -> void:
	# Keeps NPCs on the ground when walking down slopes and stairs
	floor_snap_length = 0.5
	# The buildings' stair ramps are about 46 degrees, just over the default
	floor_max_angle = deg_to_rad(50.0)
	health = stats.max_health
	target = get_tree().get_first_node_in_group("player") as Node3D
	state_machine.init(self)


func take_damage(amount: float) -> void:
	if is_dead:
		return
	last_damage_taken = amount
	state_machine.taken_hit()


func _unhandled_input(event: InputEvent) -> void:
	state_machine.process_input(event)


func _physics_process(delta: float) -> void:
	state_machine.process_physics(delta)


func _process(delta: float) -> void:
	state_machine.process_frame(delta)


## Moves the NPC one physics step towards destination, which is inside
## destination_building (or outdoors if null), at speed metres per second.
func move_towards(
	destination: Vector3, destination_building: Node3D, speed: float, delta: float
) -> void:
	var next_point: Vector3 = destination
	if current_building != destination_building and current_building != null:
		# Leave this building by its entrance first
		next_point = next_path_point(current_building.entrance_position)
	elif current_building != destination_building:
		var entrance: Vector3 = destination_building.entrance_position
		if global_position.distance_to(entrance) > ENTRANCE_REACHED_DISTANCE:
			# Straight across open ground to the entrance
			next_point = entrance
		else:
			next_point = next_path_point(destination)
	elif current_building != null:
		next_point = next_path_point(destination)

	var direction: Vector3 = next_point - global_position
	move_horizontally(direction, speed, delta)
	if Vector2(direction.x, direction.z).length() > 0.01:
		look_at(global_position + Vector3(direction.x, 0, direction.z), Vector3.UP)


## Moves the NPC one physics step in direction (ignoring its vertical part)
## at speed metres per second, falling under gravity when off the ground.
func move_horizontally(direction: Vector3, speed: float, delta: float) -> void:
	var horizontal: Vector3 = Vector3(direction.x, 0, direction.z).normalized() * speed
	var vertical: float = 0.0 if is_on_floor() else velocity.y - gravity * delta
	velocity = Vector3(horizontal.x, vertical, horizontal.z)
	move_and_slide()


## The next corner of the navigation mesh path to destination.
##
## Corners count as reached by horizontal distance: the NPC moves
## horizontally and lets physics handle height. (A NavigationAgent3D measures
## in 3D, so a corner on the buried part of a building's outer steps, directly
## below an NPC on the ground, would never count as reached.)
func next_path_point(destination: Vector3) -> Vector3:
	_path_age_secs += get_physics_process_delta_time()
	if (
		_path.is_empty()
		or _path_destination.distance_to(destination) > REPATH_DISTANCE
		or _path_age_secs > REPATH_INTERVAL_SECS
	):
		_path = NavigationServer3D.map_get_path(
			get_world_3d().navigation_map, global_position, destination, true
		)
		_path_index = 0
		_path_destination = destination
		_path_age_secs = 0.0
	if _path.is_empty():
		return destination

	while (
		_path_index < _path.size() - 1
		and horizontal_distance_to(_path[_path_index]) < (PATH_POINT_REACHED_DISTANCE)
	):
		_path_index += 1
	return _path[_path_index]


func horizontal_distance_to(point: Vector3) -> float:
	return Vector2(point.x - global_position.x, point.z - global_position.z).length()
