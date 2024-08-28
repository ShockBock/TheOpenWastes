extends Node

## Accessed and updated by many of the nodes in the building procgen creation process.

@export_group("Floorplan properties")
## Number of cells on each side of the flooplan grid.
@export_range(3, 10) var floorplan_grid_size: int = 3
## A random number of cells up to max_empty_cells will be set to EMPTY.
@export var max_empty_cells: int = 4
## How many sections (saved as individual scenes) are in each wall.
@export var number_of_sections_per_wall: int = 2
@export var floorplan_cell_size_metres: float = 8.0
@export var wall_height_metres: float = 2.0
@export var max_number_of_storeys: int = 8

## Receives, stores, updates and supplies the floorplan grid in array form.
var floorplan: Array = []
## Stores the floorplan's cells' surrounding walls on the x-axis of the grid.
var walls_array_x: Array = []
## Stores the floorplan's cells' surrounding walls on the y-axis of the grid.
var walls_array_y: Array = []

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

var walls_component_array = [
	preload("res://Scenes/buildings/building002assets/002_wall_blank.tscn"),
	preload("res://Scenes/buildings/building002assets/002_wall_windows_001.tscn"),
	preload("res://Scenes/buildings/building002assets/002_wall_windows_002.tscn"),
	preload("res://Scenes/buildings/building002assets/002_wall_windows_003.tscn"),
	]
