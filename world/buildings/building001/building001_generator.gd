@icon("res://common/icons/building_icon.png")
extends Node3D

## Assembles a randomised building001 from modular pieces: foundation and
## outer steps, external and internal walls, floors, stairwell, top floor and
## (sometimes) a roof. Each storey also gets the navigation mesh pieces that
## match its geometry.

const WALL_SECTION_HEIGHT_METRES: float = 3.0
## Positions of the eight external wall sections, two per side, going round
## the building. Sections 2n and 2n+1 share a side.
const WALL_SECTION_LOCAL_POSITIONS: Array[Vector3] = [
	Vector3(4, 0, -4),
	Vector3(0, 0, -4),
	Vector3(-4, 0, -4),
	Vector3(-4, 0, 0),
	Vector3(-4, 0, 4),
	Vector3(0, 0, 4),
	Vector3(4, 0, 4),
	Vector3(4, 0, 0),
]
const GROUND_FLOOR_WALLS: Array[String] = [
	"wall_blank", "wall_windows_001", "wall_windows_002", "wall_windows_003", "wall_two_doors"
]
const UPPER_FLOOR_WALLS: Array[String] = [
	"wall_blank", "wall_windows_001", "wall_windows_002", "wall_windows_003"
]
const BROKEN_WALLS: Array[String] = [
	"wall_blank_broken",
	"wall_windows_001_broken",
	"wall_windows_002_broken",
	"wall_windows_003_broken",
]

## Chance that a building keeps its roof; otherwise the top storey is broken
@export_range(0.0, 1.0) var roof_intact_global_probability: float = 0.25
## Building pieces by name
@export var pieces: Dictionary[String, PackedScene] = {}
## Navigation mesh pieces by name
@export var navmesh_pieces: Dictionary[String, PackedScene] = {}

var number_of_storeys: int = randi_range(1, 7)
var roof_intact_local: bool
## Which side of the foundation (0-3, in quarter turns) has the outer steps
var steps_side: int = randi_range(0, 3)


func _ready() -> void:
	roof_intact_local = randf() < roof_intact_global_probability
	build_foundation_and_steps()
	build_ground_level_external_walls()
	build_remaining_external_walls()
	build_floors()
	build_internal_walls()
	build_internal_stairwell()
	build_top_floor_stairwell()
	build_top_floor()
	build_roof()


## Instances a piece and adds it to the building.
func place(scene: PackedScene, position_metres: Vector3, quarter_turns: int = 0) -> void:
	var instance: Node3D = scene.instantiate()
	instance.position = position_metres
	instance.rotation.y = quarter_turns * PI / 2
	add_child(instance)


func storey_height(storey: int) -> float:
	return storey * WALL_SECTION_HEIGHT_METRES


func build_foundation_and_steps() -> void:
	place(pieces["foundation"], Vector3.ZERO, steps_side)
	place(navmesh_pieces["foundation_stairs_navmesh"], Vector3.ZERO, steps_side)
	place(navmesh_pieces["foundation_floor_navmesh"], Vector3.ZERO)


## Places a ring of eight wall sections at the given height. Each section
## faces outwards from its side of the building.
func build_wall_ring(wall_names: Array[String], height_metres: float) -> void:
	for section in WALL_SECTION_LOCAL_POSITIONS.size():
		var position_metres: Vector3 = WALL_SECTION_LOCAL_POSITIONS[section]
		position_metres.y = height_metres
		place(pieces[wall_names[section]], position_metres, int(section / 2.0))


func build_ground_level_external_walls() -> void:
	var walls: Array[String] = []
	for section in WALL_SECTION_LOCAL_POSITIONS.size():
		walls.append(GROUND_FLOOR_WALLS.pick_random())
	# The section facing the outer steps always has a door
	walls[steps_side * 2 + 1] = "wall_windows_doors"
	build_wall_ring(walls, 0.0)


func build_remaining_external_walls() -> void:
	for storey in number_of_storeys:
		var is_top_storey: bool = storey == number_of_storeys - 1
		var wall_type: Array[String] = (
			BROKEN_WALLS if is_top_storey and not roof_intact_local else UPPER_FLOOR_WALLS
		)
		# Every section of a storey uses the same wall type
		var wall_name: String = wall_type.pick_random()
		var walls: Array[String] = []
		walls.resize(WALL_SECTION_LOCAL_POSITIONS.size())
		walls.fill(wall_name)
		build_wall_ring(walls, storey_height(storey + 1))


func build_floors() -> void:
	for storey in number_of_storeys - 1:
		var height: float = storey_height(storey + 1)
		place(pieces["floor_stairs_hole"], Vector3(0, height, 0))
		place(navmesh_pieces["floor_stairs_hole_navmesh"], Vector3(0, height, 0))


func build_roof() -> void:
	if roof_intact_local:
		place(pieces["floor_roof"], Vector3(0, storey_height(number_of_storeys + 1), 0))


func build_internal_walls() -> void:
	for storey in number_of_storeys:
		place(pieces["wall_interior"], Vector3(0, storey_height(storey), 0))


## Alternates between two stair layouts on successive storeys.
func build_internal_stairwell() -> void:
	for storey in number_of_storeys:
		var stairs: String
		if storey == 0:
			stairs = "stairs_ground_floor"
		elif storey % 2 == 0:
			stairs = "stairs_002"
		else:
			stairs = "stairs_001"
		var height: float = storey_height(storey)
		place(pieces[stairs], Vector3(0, height, 0))
		var navmesh: String = (
			"stairs_002_ground_floor_navmesh" if storey == 0 else stairs + "_navmesh"
		)
		place(navmesh_pieces[navmesh], Vector3(0, height, 0))


func build_top_floor_stairwell() -> void:
	var blocker: String = (
		"floor_top_wall_blocker_001" if number_of_storeys % 2 == 0 else "floor_top_wall_blocker_002"
	)
	if not roof_intact_local:
		blocker += "_broken"
	place(pieces[blocker], Vector3(0, storey_height(number_of_storeys), 0))


func build_top_floor() -> void:
	var top_floor: String = "floor_top_001" if number_of_storeys % 2 == 0 else "floor_top_002"
	var height: float = storey_height(number_of_storeys)
	place(pieces[top_floor], Vector3(0, height, 0))
	place(navmesh_pieces[top_floor + "_navmesh"], Vector3(0, height, 0))
