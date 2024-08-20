@icon("res://images/Icons/building_icon.png")

extends Node

## Receives array of randomly chosen wall sections
## and instantiates them in world space.

enum CellState { EMPTY, OCCUPIED }

@export_group("Plug-in nodes")
## Plug in root / MainSequence node
@export var main_sequence_node: Node
@export var data_node: Node

var grid_size: int
var max_empty_cells: int

## Stores floorplan layout as a grid.
var floorplan: Array = []
## Stores the floorplan's cell's surrounding walls on the x-axis of the grid.
var walls_array_x: Array = []
## Stores the floorplan's cell's surrounding walls on the x-axis of the grid.
var walls_array_y: Array = []
var floorplan_cell_size_metres: float
## Stores the distance in metres each cell's walls should be translated
## relative to the centre of the building.
var cell_offsets_metres: Array = []


func sequence() -> void:
	get_grid_properties_from_data_node()
	calculate_cell_offset_array()
	DEBUG_print_grid()


func get_grid_properties_from_data_node() -> void:
	grid_size = data_node.grid_size
	max_empty_cells = data_node.max_empty_cells
	floorplan_cell_size_metres = data_node.floorplan_cell_size_metres


## Works out the (x, y) co-ordinates in metres by which to translate
## each cell's wall sections in world space
## and stores it in an array of dimensions equal to floorplan.
func calculate_cell_offset_array() -> void:
	## Works out the midpoint of one axis of the floorplan.
	## Subtracting the axis midpoint of the grid from each cell can be used to
	## 'normalise' the grid, so that the middle cell takes on (0, 0) co-ordinates.
	var floorplan_axis_midpoint = (floorplan.size() - 1) / 2.0
	
	# Works out the exact translation based on cell location for each cell
	# and stores it in an array.
	for row in range(grid_size):
		cell_offsets_metres.append([])
		for column in range(grid_size):
			cell_offsets_metres[row].append([])
			cell_offsets_metres[row][column].append(
				((column - floorplan_axis_midpoint) * floorplan_cell_size_metres)
				)
			cell_offsets_metres[row][column].append(
				((row - floorplan_axis_midpoint) * floorplan_cell_size_metres)
				)


func instantiate_walls() -> void:
	pass


func DEBUG_print_grid():
	print("Basic floorplan:")
	for row in range(grid_size):
		var line: String = ""
		for column in range(grid_size):
			if floorplan[row][column] == CellState.OCCUPIED:
				line += "[O] "
			else:
				line += "[ ] "
		print(line)
	print()
	print("Wall arrays:")
	print("Array x:")
	for row in walls_array_x.size():
		print(walls_array_x[row])
	print("Array y:")
	for column in walls_array_y.size():
		print(walls_array_y[column])
	print()
	print("cell_offsets_metres")
	print(cell_offsets_metres[0])
	print(cell_offsets_metres[1])
	print(cell_offsets_metres[2])
