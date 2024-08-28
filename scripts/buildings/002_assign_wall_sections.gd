@icon("res://images/Icons/building_icon.png")

## Chooses wall assets based on layout of floorplan.

extends Node

enum CellState { EMPTY, OCCUPIED, STAIRS }

@export_group("Plug-in nodes")
@export var main_sequence_node: Node
@export var data_node: Node

var floorplan: Array
var floorplan_grid_size: int
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
	DEBUG_print_grid()
	wall_arrays_complete.call_deferred()


## Floorplan grid is passed via a signal from the generating script as 0s and 1s.
## The enum terms are thus stripped and need reapplying.
func apply_enum_tags() -> void:
	# Gets the size of each row / column of the grid
	floorplan_grid_size = floorplan[0].size()
	
	for row in floorplan_grid_size:
		for cell_in_row in floorplan_grid_size:
			if floorplan[row][cell_in_row] == 0:
				floorplan[row][cell_in_row] = CellState.EMPTY
			elif floorplan[row][cell_in_row] == 1:
				floorplan[row][cell_in_row] = CellState.OCCUPIED
			else:
				floorplan[row][cell_in_row] = CellState.STAIRS


func get_grid_properties_from_data_node() -> void:
	floorplan = data_node.floorplan
	number_of_sections_per_wall = data_node.number_of_sections_per_wall
	floorplan_grid_size = data_node.floorplan_grid_size


## Assign placeholders for wall sections on every cell edge.
func populate_walls_array_default() -> void:
	# Add a child array for x (horizontal) axis' line of cell edges / walls.
	#
	# + 1 because there is always one more edge in a grid
	# than the rows of cells the edges line.
	for line_of_wall_edges in (floorplan_grid_size + 1):
		walls_array_x.append([])
		# Add a grandchild array for each x-axis (horizontal) wall in the line.
		for wall_edge in range(floorplan_grid_size):
			walls_array_x[line_of_wall_edges].append([])
			# Add a great-grandchild array for each section
			# making up the wall.
			for wall_section in number_of_sections_per_wall:
				walls_array_x[line_of_wall_edges][wall_edge].append([])
				walls_array_x[line_of_wall_edges][wall_edge][wall_section] = null
	
	# Add a child array for y (vertical) axis' line of cell edges / walls.
	for line_of_wall_edges in (floorplan_grid_size):
		walls_array_y.append([])
		# Add a grandchild array for each y-axis (vertical) wall in the line.
		#
		# + 1 because there is always one more edge in a grid
		# than the rows of cells the edges line.
		for wall_edge in range(floorplan_grid_size + 1):
			walls_array_y[line_of_wall_edges].append([])
			# Add a great-grandchild array for each section
			# making up the wall.
			for wall_section in number_of_sections_per_wall:
				walls_array_y[line_of_wall_edges][wall_edge].append([])
				walls_array_y[line_of_wall_edges][wall_edge][wall_section] = null
	


## Handles which function calculates walls for a given cell
## based on whether it is EMPTY or otherwise.
func assign_walls() -> void:
	for row in range(floorplan_grid_size):
		for cell_in_row in range(floorplan_grid_size):
			if floorplan[row][cell_in_row] == CellState.EMPTY:
				assign_empty_cell_walls(row, cell_in_row)
			else:
				assign_occupied_cell_walls(row, cell_in_row)


## Determines whether the EMPTY cell should have a wall above and/or to the left,
## as the result of them being next to an OCCUPIED or STAIRS cell.
func assign_empty_cell_walls(row: int, cell_in_row: int) -> void:
	if (
		not floorplan[row][cell_in_row - 1] == CellState.EMPTY
		and cell_in_row - 1 >= 0
		):
		for section in number_of_sections_per_wall:
			# Each wall is made up of multiple sections, i.e. 2.
			# The random choice of each section is saved as an array entry.
			walls_array_y[row][cell_in_row][section] = \
					randi_range(0, data_node.walls_component_array.size() - 1)
	
	if (
		not floorplan[row - 1][cell_in_row] == CellState.EMPTY
		and row - 1 >= 0
		):
		for section in number_of_sections_per_wall:
			walls_array_x[row][cell_in_row][section] = \
					randi_range(0, (data_node.walls_component_array.size() - 1))


## Determines whether the OCCUPIED cell should have a wall above and/or to the left.
## Also, determines whether the cell needs a wall below and/or to the right,
## if the OCCUPIED cell is on the bottom row.
func assign_occupied_cell_walls(row: int, cell_in_row: int) -> void:
	# Each OCCUPIED cell has a left wall.
	if (
		floorplan[row][cell_in_row - 1] == CellState.EMPTY
		or cell_in_row - 1 < 0
		):
		for section in number_of_sections_per_wall:
			# Each wall is made up of multiple sections, i.e. 2.
			# The random choice of each section is saved as an array entry.
			walls_array_y[row][cell_in_row][section] = \
					randi_range(0, data_node.walls_component_array.size() - 1)
	
	#  Each OCCUPIED cell has a wall above.
	if (
		floorplan[row - 1][cell_in_row] == CellState.EMPTY
		or row - 1 < 0
		):
		for section in number_of_sections_per_wall:
			walls_array_x[row][cell_in_row][section] = \
					randi_range(0, (data_node.walls_component_array.size() - 1))
	
	# If this cell is in the last column (cell_in_row), assign a wall to the right.
	if cell_in_row == floorplan_grid_size - 1:
		for section in number_of_sections_per_wall:
			walls_array_y[row][cell_in_row + 1][section] = \
					randi_range(0, data_node.walls_component_array.size() - 1)
	
	# If this cell is in the last row (row), assign a wall below.
	if row == floorplan_grid_size - 1:
		for section in number_of_sections_per_wall:
			walls_array_x[row + 1][cell_in_row][section] = \
					randi_range(0, (data_node.walls_component_array.size() - 1))


## Passes the two completed wall arrays (x and y) to the main sequence node
## for distribution to the nodes which instantiate the wall assets.
func wall_arrays_complete() -> void:
	data_node.walls_array_x = walls_array_x
	data_node.walls_array_y = walls_array_y
	main_sequence_node.wall_arrays_finished()


## Call this for a diagram of the floorplan, showing OCCUPIED and EMPTY cells
## and for the arrays which hold the indeces of the cells' walls.
func DEBUG_print_grid():
	print_rich("[b]Basic floorplan:[/b]")
	print("O = occupied, S = stairwell")
	for row in range(floorplan_grid_size):
		var line: String = ""
		for cell in range(floorplan_grid_size):
			if floorplan[row][cell] == CellState.OCCUPIED:
				line += "[O] "
			elif floorplan[row][cell] == CellState.STAIRS:
				line += "[S] "
			else:
				line += "[ ] "
		print(line)
	print()
	print_rich("[b]Wall arrays:[/b]")
	print("Array x:")
	for row in walls_array_x.size():
		print(walls_array_x[row])
	print("Array y:")
	for row in walls_array_y.size():
		print(walls_array_y[row])
