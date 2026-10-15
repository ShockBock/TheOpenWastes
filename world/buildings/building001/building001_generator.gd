@icon("res://common/icons/building_icon.png")
extends Node3D

## Assembles a randomised building001 from modular pieces: foundation and
## outer steps, external and internal walls, floors, stairwell, top floor and
## (sometimes) a roof.
##
## For NPCs to follow the player indoors, the building also:
## - merges the navigation mesh pieces that match its geometry into a single
##   navigation mesh, baked in the background, so paths run up every storey;
## - marks its entrance_position, where the outer steps meet the ground;
## - tracks which characters are inside it, through an interior Area3D, by
##   setting their current_building.

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

## Set by the building placer; used to find where the outer steps meet the
## ground. Without it, the entrance is the bottom of the steps.
var terrain: TerrainManager
## Where the outer steps meet the ground, in global coordinates. NPCs outdoors
## walk here before following the building's navigation mesh.
var entrance_position: Vector3
var navigation_region: NavigationRegion3D
var number_of_storeys: int = randi_range(1, 7)
var roof_intact_local: bool
## Which side of the foundation (0-3, in quarter turns) has the outer steps
var steps_side: int = randi_range(0, 3)

var _navigation_source: NavigationMeshSourceGeometryData3D = (
	NavigationMeshSourceGeometryData3D.new()
)
## Vertices of the outer steps' navigation mesh, in building space
var _steps_vertices: PackedVector3Array = []


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
	find_entrance()
	build_interior_area()
	bake_navigation_mesh()


## Instances a piece and adds it to the building.
func place(scene: PackedScene, position_metres: Vector3, quarter_turns: int = 0) -> void:
	var instance: Node3D = scene.instantiate()
	instance.position = position_metres
	instance.rotation.y = quarter_turns * PI / 2
	add_child(instance)


## Adds a navigation mesh piece's polygons to the building's navigation source
## geometry, and returns its vertices in building space. The piece itself is
## not kept in the scene.
func add_navmesh_piece(
	scene: PackedScene, position_metres: Vector3, quarter_turns: int = 0
) -> PackedVector3Array:
	var placement: Transform3D = Transform3D(
		Basis(Vector3.UP, quarter_turns * PI / 2), position_metres
	)
	var instance: Node = scene.instantiate()
	var vertices: PackedVector3Array = []
	for region: NavigationRegion3D in instance.find_children(
		"*", "NavigationRegion3D", true, false
	):
		# The region's transform relative to the piece's root
		var local: Transform3D = Transform3D.IDENTITY
		var node: Node = region
		while node != instance:
			local = node.transform * local
			node = node.get_parent()
		var to_building: Transform3D = placement * local

		var mesh: NavigationMesh = region.navigation_mesh
		var faces: PackedVector3Array = []
		for polygon_index in mesh.get_polygon_count():
			var polygon: PackedInt32Array = mesh.get_polygon(polygon_index)
			for i in range(1, polygon.size() - 1):
				faces.append(to_building * mesh.vertices[polygon[0]])
				faces.append(to_building * mesh.vertices[polygon[i]])
				faces.append(to_building * mesh.vertices[polygon[i + 1]])
		_navigation_source.add_faces(faces, Transform3D.IDENTITY)
		for vertex in mesh.vertices:
			vertices.append(to_building * vertex)
	instance.free()
	return vertices


func storey_height(storey: int) -> float:
	return storey * WALL_SECTION_HEIGHT_METRES


func build_foundation_and_steps() -> void:
	place(pieces["foundation"], Vector3.ZERO, steps_side)
	_steps_vertices = add_navmesh_piece(
		navmesh_pieces["foundation_stairs_navmesh"], Vector3.ZERO, steps_side
	)
	add_navmesh_piece(navmesh_pieces["foundation_floor_navmesh"], Vector3.ZERO)


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
		add_navmesh_piece(navmesh_pieces["floor_stairs_hole_navmesh"], Vector3(0, height, 0))


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
		add_navmesh_piece(navmesh_pieces[navmesh], Vector3(0, height, 0))


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
	add_navmesh_piece(navmesh_pieces[top_floor + "_navmesh"], Vector3(0, height, 0))


## Finds where the outer steps meet the ground, walking down them from the
## top until they reach the terrain.
func find_entrance() -> void:
	var top_y: float = -INF
	var bottom_y: float = INF
	for vertex in _steps_vertices:
		top_y = max(top_y, vertex.y)
		bottom_y = min(bottom_y, vertex.y)
	var top: Vector3 = average_of_vertices_at_height(top_y)
	var bottom: Vector3 = average_of_vertices_at_height(bottom_y)

	entrance_position = to_global(bottom)
	if terrain == null:
		return
	const SAMPLES: int = 50
	for i in SAMPLES + 1:
		var point: Vector3 = to_global(top.lerp(bottom, float(i) / SAMPLES))
		var ground: float = terrain.height_at(point.x, point.z)
		if point.y <= ground:
			entrance_position = Vector3(point.x, ground, point.z)
			return


func average_of_vertices_at_height(height: float) -> Vector3:
	var total: Vector3 = Vector3.ZERO
	var count: int = 0
	for vertex in _steps_vertices:
		if is_equal_approx(vertex.y, height):
			total += vertex
			count += 1
	return total / count


## An Area3D filling the building's walls, which sets current_building on any
## character (player or NPC) that enters it.
func build_interior_area() -> void:
	var height: float = storey_height(number_of_storeys + 1)
	var shape: BoxShape3D = BoxShape3D.new()
	shape.size = Vector3(9, height, 9)
	var collision_shape: CollisionShape3D = CollisionShape3D.new()
	collision_shape.shape = shape
	collision_shape.position.y = height / 2
	var area: Area3D = Area3D.new()
	area.name = "Interior"
	area.add_child(collision_shape)
	area.body_entered.connect(_on_interior_body_entered)
	area.body_exited.connect(_on_interior_body_exited)
	add_child(area)


func _on_interior_body_entered(body: Node3D) -> void:
	if "current_building" in body:
		body.current_building = self


func _on_interior_body_exited(body: Node3D) -> void:
	if "current_building" in body and body.current_building == self:
		body.current_building = null


## Merges the navigation mesh pieces into one navigation mesh, so that paths
## join up between floors and stairs. Baked on a background thread.
func bake_navigation_mesh() -> void:
	var navigation_mesh: NavigationMesh = NavigationMesh.new()
	# No erosion: the stair strips are under a metre wide
	navigation_mesh.agent_radius = 0.0
	navigation_mesh.agent_height = 1.5
	navigation_mesh.agent_max_climb = 0.5
	navigation_mesh.agent_max_slope = 50.0
	NavigationServer3D.bake_from_source_geometry_data_async(
		navigation_mesh, _navigation_source, _on_navigation_mesh_baked.bind(navigation_mesh)
	)


func _on_navigation_mesh_baked(navigation_mesh: NavigationMesh) -> void:
	if not is_inside_tree():
		return
	navigation_region = NavigationRegion3D.new()
	navigation_region.name = "NavigationRegion"
	navigation_region.navigation_mesh = navigation_mesh
	add_child(navigation_region)
