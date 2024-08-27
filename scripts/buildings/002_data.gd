extends Node

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

var walls_component_array = [
	preload("res://Scenes/buildings/building002assets/002_wall_blank.tscn"),
	preload("res://Scenes/buildings/building002assets/002_wall_windows_001.tscn"),
	preload("res://Scenes/buildings/building002assets/002_wall_windows_002.tscn"),
	preload("res://Scenes/buildings/building002assets/002_wall_windows_003.tscn"),
	]
