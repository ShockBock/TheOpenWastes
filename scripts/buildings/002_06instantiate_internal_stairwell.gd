@icon("res://images/Icons/building_icon.png")

extends Node

enum CellState { EMPTY, OCCUPIED, STAIRS }

## Generates stairwell as determined by floorplan grid.

@export_group("Plug-in nodes")
## Plug in root / MainSequence node
@export var main_sequence_node: Node
@export var data_node: Node

var right_angle_rotation: float = PI / 2

var cell_offsets_metres_array: Array = []
## Stores floorplan layout as a grid.
var floorplan: Array = []
var floorplan_cell_size_metres: float
## Stores distance in metres each wall section should be translated
## as the result of the 'parent' cell's position.
var floorplan_grid_size: int
var stairs_asset_dictionary: Dictionary
var stairs_displacement_metres: Vector3
var wall_height_metres: float


func sequence(storey) -> void:
	get_data()
	get_cell_offset()
	instantiate_stairs(storey)


func get_data() -> void:
	cell_offsets_metres_array = data_node.cell_offsets_metres_array
	floorplan = data_node.floorplan
	floorplan_grid_size = data_node.floorplan_grid_size
	floorplan_cell_size_metres = data_node.floorplan_cell_size_metres
	wall_height_metres = data_node.wall_height_metres


func get_cell_offset() -> void:
	for row in range(floorplan_grid_size):
		for cell_in_row in range(floorplan_grid_size):
			if not floorplan[row][cell_in_row] == CellState.STAIRS:
				pass
			else:
				stairs_displacement_metres = \
						data_node.cell_offsets_metres_array[row][cell_in_row]


func instantiate_stairs(storey) -> void:
	var stairs_instance: Node3D
	if storey == 0:
		stairs_instance = Building002Assets.stairs_asset_dictionary \
				["002_stairs_002_ground_floor"].instantiate()
	elif storey % 2 == 0:
		stairs_instance = Building002Assets.stairs_asset_dictionary \
				["002_stairs_001"].instantiate()
	elif storey % 2 == 1:
		stairs_instance = Building002Assets.stairs_asset_dictionary \
				["002_stairs_002"].instantiate()
	else:
		pass
	# Add cell translation.
	stairs_instance.position += stairs_displacement_metres
	# Add storey translation.
	stairs_instance.position.y += storey * wall_height_metres
	add_child(stairs_instance)
