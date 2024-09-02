@icon("res://images/Icons/building_icon.png")

extends Node

enum CellState { EMPTY, OCCUPIED, STAIRS }

## Generates stairwell as determined by floorplan grid.

@export_group("Plug-in nodes")
## Plug in root / MainSequence node
@export var main_sequence_node: Node
@export var data_node: Node

var right_angle_rotation: float = PI / 2

var cell_offsets_metres_array: Array = []
## Stores floorplan layout as a grid.
var floorplan: Array = []
var floorplan_cell_size_metres: float
## Stores distance in metres each wall section should be translated
## as the result of the 'parent' cell's position.
var floorplan_grid_size: int
var walls_array_x: Array = []
var walls_array_y: Array = []
var wall_height_metres: float
var foundation_stairs: PackedScene
## Determines where to place foundation steps, relative to foundation block.
var foundation_origin_to_edge_metres: float


func sequence() -> void:
	get_data()
	calculate_foundation_stairs_locations()


func get_data() -> void:
	cell_offsets_metres_array = data_node.cell_offsets_metres_array
	floorplan = data_node.floorplan
	floorplan_grid_size = data_node.floorplan_grid_size
	floorplan_cell_size_metres = data_node.floorplan_cell_size_metres
	wall_height_metres = data_node.wall_height_metres
	walls_array_x = data_node.walls_array_x
	walls_array_y = data_node.walls_array_y
	foundation_origin_to_edge_metres = data_node.foundation_length_metres / 2
	foundation_stairs = Building002Assets.foundation_stairs


func calculate_foundation_stairs_locations() -> void:
	# Calculate positions of stairs on top row (array_x).
	for cell_in_row in walls_array_x[0].size():
		for wall_section in walls_array_x[0][cell_in_row].size():
			print(walls_array_x[0][cell_in_row][wall_section])
			if not walls_array_x[0][cell_in_row][wall_section] == 0:
				pass
			else:
				var foundation_stairs_instance: Node3D = foundation_stairs.instantiate()
				foundation_stairs_instance.position.z -= foundation_origin_to_edge_metres
				foundation_stairs_instance.position.x += 0
				add_child(foundation_stairs_instance)
			
	# Calculate positions of stairs on bottom row (array_x).
	
	# Calculate positions of stairs on left row (array_y).
	
	# Calculate positions of stairs on right row (array_y).
	
	pass
