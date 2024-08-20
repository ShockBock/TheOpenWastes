@icon("res://images/Icons/building_icon.png")

## Chooses wall assets based on layout of floorplan.

extends Node

enum CellState { EMPTY, OCCUPIED }

@export_group("Plug-in nodes")
@export var main_sequence_node: Node
@export var data_node: Node

var floorplan: Array
var grid_size: int
## Each wall is made up of multiple sections, i.e. 2.
var number_of_sections_per_wall: int

## Stores the wall sections on the x-axis chosen to surround the OCCUPIED cells.
var walls_array_x: Array = []
## Stores the wall sections on the y-axis chosen to surround the OCCUPIED cells.
var walls_array_y: Array = []

func sequence() -> void:
	get_grid_properties_from_data_node()
	apply_enum_tags()
	populate_walls_array_default()
	assign_walls()
	wall_arrays_complete.call_deferred()


## Floorplan grid is passed via a signal from the generating script as 0s and 1s.
## The enum terms are thus stripped and need reaplying.
func apply_enum_tags() -> void:
	# Gets the size of each row / column of the grid
	grid_size = floorplan[0].size()
	
	for row in grid_size:
		for column in grid_size:
			if floorplan[row][column] == 0:
				floorplan[row][column] = CellState.EMPTY
			else:
				floorplan[row][column] = CellState.OCCUPIED


func get_grid_properties_from_data_node() -> void:
	number_of_sections_per_wall = data_node.number_of_sections_per_wall
	grid_size = data_node.grid_size


## Assign placeholders for wall sections on every cell edge.
func populate_walls_array_default() -> void:
	
	# Add a child array for each axis' line of cell edges / walls.
	#
	# + 1 because there is always one more edge in a grid
	# than the rows of cells the edges line.
	for line_of_wall_edges in (grid_size + 1):
		walls_array_x.append([])
		walls_array_y.append([])
		# Add a grandchild array for each single-cell wall in the line.
		for wall_edge in range(grid_size):
			walls_array_x[line_of_wall_edges].append([])
			walls_array_y[line_of_wall_edges].append([])
			# Add a great-grandchild array for each section
			# making up the wall.
			for wall_section in number_of_sections_per_wall:
				walls_array_x[line_of_wall_edges][wall_edge].append([])
				walls_array_x[line_of_wall_edges][wall_edge][wall_section] = null
				walls_array_y[line_of_wall_edges][wall_edge].append([])
				walls_array_y[line_of_wall_edges][wall_edge][wall_section] = null

## Handles which function calculates walls for a given cell
## based on whether it is EMPTY or OCCUPIED.
func assign_walls() -> void:
	for row in range(grid_size):
		for column in range(grid_size):
			if floorplan[row][column] == CellState.EMPTY:
				assign_empty_cell_walls(row, column)
			else:
				assign_occupied_cell_walls(row, column)


## Determines whether the EMPTY cell should have a wall above and/or to the left,
## as the result of them being next to an OCCUPIED cell.
func assign_empty_cell_walls(row: int, column: int) -> void:
	if floorplan[row][column - 1] == CellState.OCCUPIED and column - 1 >= 0:
		for section in number_of_sections_per_wall:
			# Each wall is made up of multiple sections, i.e. 2.
			# The random choice of each section is saved as an array entry.
			walls_array_y[column][row][section] = \
					randi_range(0, data_node.walls_component_array.size() - 1)
	
	if floorplan[row - 1][column] == CellState.OCCUPIED and row - 1 >= 0:
		for section in number_of_sections_per_wall:
			walls_array_x[row][column][section] = \
					randi_range(0, (data_node.walls_component_array.size() - 1))


## Determines whether the OCCUPIED cell should have a wall above and/or to the left.
## Also, determines whether the cell needs a wall below and/or to the right,
## if the OCCUPIED cell is on the bottom row.
func assign_occupied_cell_walls(row: int, column: int) -> void:
	# Each OCCUPIED cell has two walls placed: left and above.
	if floorplan[row][column - 1] == CellState.EMPTY or column - 1 < 0:
		for section in number_of_sections_per_wall:
			# Each wall is made up of multiple sections, i.e. 2.
			# The random choice of each section is saved as an array entry.
			walls_array_y[column][row][section] = \
					randi_range(0, data_node.walls_component_array.size() - 1)
	
	if floorplan[row - 1][column] == CellState.EMPTY or row - 1 < 0:
		for section in number_of_sections_per_wall:
			walls_array_x[row][column][section] = \
					randi_range(0, (data_node.walls_component_array.size() - 1))
	
	# If this cell is in the last column (column), place a wall to the right.
	if column == grid_size - 1:
		for section in number_of_sections_per_wall:
			walls_array_y[column + 1][row][section] = \
					randi_range(0, data_node.walls_component_array.size() - 1)
	
	# If this cell is in the last row (row), place a wall below.
	if row == grid_size - 1:
		for section in number_of_sections_per_wall:
			walls_array_x[row + 1][column][section] = \
					randi_range(0, (data_node.walls_component_array.size() - 1))

## Passes the two completed wall arrays (x and y) to the main sequence node
## for distribution to the nodes which instantiate the wall assets.
func wall_arrays_complete() -> void:
	main_sequence_node.pass_walls_arrays(walls_array_x, walls_array_y)
