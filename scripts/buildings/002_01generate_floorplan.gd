@icon("res://images/Icons/building_icon.png")

extends Node

## Building floorplan generator.
## 
## Sets up a grid whose sides' length = floorplan_grid_size.
## It sets all grid's cell to OCCUPIED,
## then re-assigns an amount of cells up to max_empty_cells as EMPTY.
## However, it will only set a cell to EMPTY if this does not disconnect an OCCUPIED cell.
##																[br]
## Example:														[br]
##																[br]
## [O] [O] [ ]													[br]
## [O] [O] [O]													[br]
## [O] [ ] [ ]													[br]
##																[br]
## Where 'O' = OCCUPIED.										[br]
##																[br]
## ChatGPT takes the majority of the credit for this one!

enum CellState { EMPTY, OCCUPIED, STAIRS }

@export_group("Plug-in nodes")
@export var main_sequence_node: Node
@export var data_node: Node

var floorplan_grid_size: int
var max_empty_cells: int

## Stores floorplan layout as a grid.
var floorplan: Array = []
var floorplan_cell_size_metres: int
## Stores the offset in metres of each cell relative to the floorplan's mid-point.
var cell_offsets_metres_array: Array = []


func _ready():
	get_grid_properties_from_data_node()
	initialise_the_grid_with_all_cells_occupied()
	randomly_empty_cells()
	assign_stairwell()
	calculate_cell_offset_array()
	floorplan_complete.call_deferred()


func get_grid_properties_from_data_node() -> void:
	floorplan_grid_size = data_node.floorplan_grid_size
	max_empty_cells = data_node.max_empty_cells
	floorplan_cell_size_metres = data_node.floorplan_cell_size_metres
	cell_offsets_metres_array = data_node.cell_offsets_metres_array


func initialise_the_grid_with_all_cells_occupied() -> void:
	floorplan = []
	for row in range(floorplan_grid_size):
		floorplan.append([])
		for column in range(floorplan_grid_size):
			floorplan[row].append(CellState.OCCUPIED)


func randomly_empty_cells() -> void:
	var empty_cells: Array = []
	var instance_empty_cells: int = max_empty_cells - randi_range(0, max_empty_cells)
	while len(empty_cells) < instance_empty_cells:
		var row: int = randi() % floorplan_grid_size
		var cell_in_row: int = randi() % floorplan_grid_size
		if floorplan[row][cell_in_row] == CellState.OCCUPIED:
			floorplan[row][cell_in_row] = CellState.EMPTY
			empty_cells.append(Vector2(row, cell_in_row))
			if not are_all_occupied_cells_connected():
				# If removing this cell disconnects the floorplan, undo it
				floorplan[row][cell_in_row] = CellState.OCCUPIED
				empty_cells.pop_back()


## Check if all OCCUPIED cells are connected
func are_all_occupied_cells_connected() -> bool:
	var visited: Array = []
	for row in range(floorplan_grid_size):
		visited.append([])
		for cell_in_row in range(floorplan_grid_size):
			visited[row].append(false)
	
	# Find the first occupied cell to start the flood fill
	var start = null
	for row in range(floorplan_grid_size):
		for cell_in_row in range(floorplan_grid_size):
			if floorplan[row][cell_in_row] == CellState.OCCUPIED:
				start = Vector2(row, cell_in_row)
				break
		if start != null:
			break
	
	if start == null:
		return true  # No occupied cells
	
	# Use flood fill to check connectivity
	flood_fill(start.x, start.y, visited)
	
	# Check if all occupied cells were visited
	for row in range(floorplan_grid_size):
		for cell_in_row in range(floorplan_grid_size):
			if (
				floorplan[row][cell_in_row] == CellState.OCCUPIED 
				and not visited[row][cell_in_row]
				):
				return false
	
	return true

## Flood fill algorithm to check connectivity
func flood_fill(x: int, y: int, visited: Array):
	# Check if the coordinates are out of bounds
	if (x < 0 or x >= floorplan_grid_size or
		y < 0 or y >= floorplan_grid_size):
		return
	
	# Check if the cell is already visited or if it is EMPTY
	if visited[x][y] or floorplan[x][y] == CellState.EMPTY:
		return
	
	# Mark the current cell as visited
	visited[x][y] = true
	
	# Recursively call flood_fill on all four neighbouring cells (up, down, left, right)
	flood_fill(x + 1, y, visited)  # right
	flood_fill(x - 1, y, visited)  # left
	flood_fill(x, y + 1, visited)  # down
	flood_fill(x, y - 1, visited)  # up


func assign_stairwell() -> void:
	var random_row = randi_range(0, floorplan_grid_size - 1)
	var random_cell_in_row = randi_range(0, floorplan_grid_size - 1)
	if floorplan[random_row][random_cell_in_row] == CellState.EMPTY:
		assign_stairwell()
	else:
		floorplan[random_row][random_cell_in_row] = CellState.STAIRS


## Works out the (x, y) co-ordinates in metres by which to translate
## each cell relative to the centre of the grid.
func calculate_cell_offset_array() -> void:
	## Works out the midpoint of one axis of the floorplan.
	## Subtracting the axis midpoint of the grid from each cell can be used to
	## 'normalise' the grid, so that the middle cell takes on (0, 0) co-ordinates.
	var floorplan_axis_midpoint = (floorplan.size() - 1) / 2.0
	
	# Works out the exact translation based on cell location for each cell
	# and stores it in an array.
	for row in range(floorplan_grid_size):
		cell_offsets_metres_array.append([])
		for cell_in_row in range(floorplan_grid_size):
			var cell_offset_metres: Vector3
			cell_offset_metres.x = (
				((cell_in_row - floorplan_axis_midpoint) * floorplan_cell_size_metres)
				)
			cell_offset_metres.y = 0
			cell_offset_metres.z = (
				((floorplan_axis_midpoint - row) * floorplan_cell_size_metres)
				)
			cell_offsets_metres_array[row].append(cell_offset_metres)
	
	# Store array in data node for access by other nodes.
	data_node.cell_offsets_metres_array = cell_offsets_metres_array


func floorplan_complete() -> void:
	data_node.floorplan = floorplan
	main_sequence_node.floorplan_complete()
