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

func _ready():
	get_grid_properties_from_data_node()
	initialise_the_grid_with_all_cells_occupied()
	randomly_empty_cells()
	assign_stairwell()
	floorplan_complete.call_deferred()


func get_grid_properties_from_data_node() -> void:
	floorplan_grid_size = data_node.floorplan_grid_size
	max_empty_cells = data_node.max_empty_cells


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


func floorplan_complete() -> void:
	data_node.floorplan = floorplan
	main_sequence_node.floorplan_complete()
