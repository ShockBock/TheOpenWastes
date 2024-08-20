@icon("res://images/Icons/building_icon.png")

extends Node

## Building floorplan generator.
## 
## Sets up a grid whose sides' length = grid_size.
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

enum CellState { EMPTY, OCCUPIED }

@export_group("Plug-in nodes")
@export var main_sequence_node: Node
@export var data_node: Node

var grid_size: int
var max_empty_cells: int

## Stores floorplan layout as a grid.
var grid: Array = []

func _ready():
	get_grid_properties_from_data_node()
	initialise_the_grid_with_all_cells_occupied()
	randomly_empty_cells()
	floorplan_complete.call_deferred()


func get_grid_properties_from_data_node() -> void:
	grid_size = data_node.grid_size
	max_empty_cells = data_node.max_empty_cells


func initialise_the_grid_with_all_cells_occupied() -> void:
	grid = []
	for row in range(grid_size):
		grid.append([])
		for column in range(grid_size):
			grid[row].append(CellState.OCCUPIED)


func randomly_empty_cells() -> void:
	var empty_cells: Array = []
	var instance_empty_cells: int = max_empty_cells - randi_range(0, max_empty_cells)
	while len(empty_cells) < instance_empty_cells:
		var x: int = randi() % grid_size
		var y: int = randi() % grid_size
		if grid[x][y] == CellState.OCCUPIED:
			grid[x][y] = CellState.EMPTY
			empty_cells.append(Vector2(x, y))
			if not are_all_occupied_cells_connected():
				# If removing this cell disconnects the grid, undo it
				grid[x][y] = CellState.OCCUPIED
				empty_cells.pop_back()


## Check if all OCCUPIED cells are connected
func are_all_occupied_cells_connected() -> bool:
	var visited: Array = []
	for i in range(grid_size):
		visited.append([])
		for j in range(grid_size):
			visited[i].append(false)
	
	# Find the first occupied cell to start the flood fill
	var start = null
	for row in range(grid_size):
		for column in range(grid_size):
			if grid[row][column] == CellState.OCCUPIED:
				start = Vector2(row, column)
				break
		if start != null:
			break
	
	if start == null:
		return true  # No occupied cells
	
	# Use flood fill to check connectivity
	flood_fill(start.x, start.y, visited)
	
	# Check if all occupied cells were visited
	for row in range(grid_size):
		for column in range(grid_size):
			if grid[row][column] == CellState.OCCUPIED and not visited[row][column]:
				return false
	
	return true

## Flood fill algorithm to check connectivity
func flood_fill(x: int, y: int, visited: Array):
	# Check if the coordinates are out of bounds
	if (x < 0 or x >= grid_size or
		y < 0 or y >= grid_size):
		return
	
	# Check if the cell is already visited or if it is EMPTY
	if visited[x][y] or grid[x][y] == CellState.EMPTY:
		return
	
	# Mark the current cell as visited
	visited[x][y] = true
	
	# Recursively call flood_fill on all four neighbouring cells (up, down, left, right)
	flood_fill(x + 1, y, visited)  # right
	flood_fill(x - 1, y, visited)  # left
	flood_fill(x, y + 1, visited)  # down
	flood_fill(x, y - 1, visited)  # up


func floorplan_complete() -> void:
	main_sequence_node.pass_floorplan(grid)
