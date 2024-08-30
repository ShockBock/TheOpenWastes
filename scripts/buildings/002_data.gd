extends Node

## Accessed and updated by many of the nodes in the building procgen creation process.

@export_group("Floorplan properties")
@export var floorplan_cell_size_metres: float = 8.0
## Number of cells on each side of the flooplan grid.
@export_range(3, 10) var floorplan_grid_size: int = 3
## A random number of cells up to max_empty_cells will be set to EMPTY.
@export var max_empty_cells: int = 4
## How many sections (saved as individual scenes) are in each wall.
@export var max_number_of_storeys: int = 8
## Minimum number of external doors on outer face of lowest floor of building.
@export var min_number_of_external_doors: int = 2
## Maximum number of external doors on outer face of lowest floor of building.
@export var max_number_of_external_doors: int = 2
@export var number_of_sections_per_wall: int = 2
## Determines the height of one storey, based on wall height (metres).
@export var wall_height_metres: float = 3.0


## Stores the floorplan grid in array form.
var floorplan: Array = []
## Stores the floorplan's cells' surrounding walls on the x-axis of the grid
## in numerical form, for accessing walls_component_array.
var walls_array_x: Array = []
## Stores the floorplan's cells' surrounding walls on the y-axis of the grid
## in numerical form, for accessing walls_component_array.
var walls_array_y: Array = []
## Stores the offset in metres of each cell relative to the floorplan's mid-point.
var cell_offsets_metres_array: Array = []

## Stores distance in metres each wall section should be translated
## relative to 'parent' cell.
var wall_section_local_positions_metres_array: Array[Vector3] = [
	Vector3(-4, 0, -4),
	Vector3(-4, 0, 0),
	Vector3(-4, 0, 4),
	Vector3(0, 0, 4),
	Vector3(4, 0, 4),
	Vector3(4, 0, 0),
	Vector3(4, 0, -4),
	Vector3(0, 0, -4),
	]
