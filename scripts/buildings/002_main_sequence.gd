@icon("res://images/Icons/building_icon.png")

@tool

extends Node3D

## Co-ordinates the procedural generation of Building002.

enum CellState { EMPTY, OCCUPIED }

## Stores the floorplan of the building in grid format,
## with each cell taking a CellState value.
var floorplan: Array
## Size of one of the floorplan grid's sides.
var grid_size: int
## Each wall is made up of multiple sections.
var number_of_sections_per_wall: int = 2

## Stores the walls on the x-axis chosen to surround the OCCUPIED cells.
var walls_x: Dictionary
## Stores the walls on the y-axis chosen to surround the OCCUPIED cells.
var walls_y: Dictionary

var building_component_dictionary = {
	"002_foundation_base" : preload("res://Scenes/buildings/building002assets/002_foundation_base.tscn"),
	}

var walls_component_array = [
	preload("res://Scenes/buildings/building002assets/002_wall_blank.tscn"),
	preload("res://Scenes/buildings/building002assets/002_wall_windows_001.tscn"),
	preload("res://Scenes/buildings/building002assets/002_wall_windows_002.tscn"),
	preload("res://Scenes/buildings/building002assets/002_wall_windows_003.tscn"),
	]

# Called when the node enters the scene tree for the first time.
func _ready():
	instantiate_base()


func instantiate_base() -> void:
	var foundation_base = building_component_dictionary["002_foundation_base"]
	var foundation_base_instance = foundation_base.instantiate()
	add_child(foundation_base_instance)


## Receives completed floorplan in Array format from the GenerateFloorplan node.
func _on_generate_floorplan_floorplan_complete(grid):
	floorplan = grid
	apply_enum_tags()
	DEBUG_print_grid()
	assign_walls()


## Floorplan grid is passed via a signal from the generating script as 0s and 1s.
## The enum terms are thus stripped and need reaplying.
func apply_enum_tags() -> void:
	# Gets the size of each row / column of the grid
	grid_size = floorplan[0].size()
	
	for i in grid_size:
		for j in grid_size:
			if floorplan[i][j] == 0:
				floorplan[i][j] = CellState.EMPTY
			else:
				floorplan[i][j] = CellState.OCCUPIED

## Runs through each cell in the grid,
## calling a function to assign walls if the cell is OCCUPIED.
func assign_walls() -> void:
	for i in range(grid_size):
		for j in range(grid_size):
			if floorplan[i][j] == CellState.EMPTY:
				assign_empty_cell_walls(i, j)
			else:
				assign_occupied_cell_walls(i, j)

## Determines whether the EMPTY cell should have a wall above and/or to the left.
func assign_empty_cell_walls(i: int, j: int) -> void:
	if floorplan[i][j - 1] == CellState.OCCUPIED and j - 1 >= 0:
		prints(i, j, "empty: place a wall left")
		
		for section in number_of_sections_per_wall:
			# Each wall is made up of multiple sections, i.e. 2.
			# The random choice of each section is saved as a dictionary entry
			# whose key contains the x, y location of the overall wall
			# and the section's place within the wall.
			
			walls_x["x" + str(i) + "y" + str(j) + "section" + str(section)] = \
					walls_component_array[randi_range(0, walls_component_array.size() - 1)]
			
			var wall = walls_x["x" + str(i) + "y" + str(j) + "section" + str(section)]
			var wall_instance = wall.instantiate()
			add_child(wall_instance)

		
		
	if floorplan[i - 1][j] == CellState.OCCUPIED and i - 1 >= 0:
		prints(i, j, "empty: place a wall above")

## Determines whether the OCCUPIED cell should have a wall above and/or to the left.
## Also, determines whether the cell needs a wall below and/or to the right,
## if the OCCUPIED cell is on the bottom row.
func assign_occupied_cell_walls(i: int, j: int) -> void:
	# Each OCCUPIED cell has two walls placed: left and above.
	if floorplan[i][j - 1] == CellState.EMPTY or j - 1 < 0:
		prints(i, j, "occupied: place a wall left")
	
	if floorplan[i - 1][j] == CellState.EMPTY or i - 1 < 0:
		prints(i, j, "occupied: place a wall above")
	
	# If this cell is in the last column (j), place a wall to the right.
	if j == grid_size - 1:
		prints(i,j,"occupied: place a wall right")
	# If this cell is in the last row (i), place a wall below.
	if i == grid_size - 1:
		prints(i,j,"occupied: place a wall below")


func DEBUG_print_grid():
	for i in range(grid_size):
		var line: String = ""
		for j in range(grid_size):
			if floorplan[i][j] == CellState.OCCUPIED:
				line += "[O] "
			else:
				line += "[ ] "
		print(line)
