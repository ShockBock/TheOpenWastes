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
var number_of_sections_per_wall: int
var walls_array_x: Array = []
var walls_array_y: Array = []
var wall_height_metres: float
var wall_length_metres: float
var foundation_stairs: PackedScene
## Determines where to place foundation steps, relative to foundation block.
var foundation_origin_to_edge_metres: float


func sequence() -> void:
	get_data()
	instantiate_foundation_stairs_sequence()


func get_data() -> void:
	cell_offsets_metres_array = data_node.cell_offsets_metres_array
	floorplan = data_node.floorplan
	floorplan_grid_size = data_node.floorplan_grid_size
	floorplan_cell_size_metres = data_node.floorplan_cell_size_metres
	number_of_sections_per_wall = data_node.number_of_sections_per_wall
	wall_height_metres = data_node.wall_height_metres
	wall_length_metres = data_node.wall_length_metres
	walls_array_x = data_node.walls_array_x
	walls_array_y = data_node.walls_array_y
	foundation_origin_to_edge_metres = data_node.foundation_length_metres / 2
	foundation_stairs = Building002Assets.foundation_stairs


func instantiate_foundation_stairs_sequence() -> void:
	instantiate_stairs_on_top_row()
	instantiate_stairs_on_bottom_row()
	instantiate_stairs_on_left_row()
	instantiate_stairs_on_right_row()


## Calculate positions of stairs on top row (array_x).
func instantiate_stairs_on_top_row() -> void:
	# Calculate position of first wall in top row, whether it's null or not.
	var first_wall_section_in_array_x_top_row_position: Vector3
	first_wall_section_in_array_x_top_row_position.x -= floorplan_cell_size_metres
	first_wall_section_in_array_x_top_row_position.z += floorplan_cell_size_metres
	first_wall_section_in_array_x_top_row_position.x -= wall_length_metres
	first_wall_section_in_array_x_top_row_position.z += wall_length_metres
	
	var offset_due_wall_section_origin: float = wall_length_metres / 2
	for cell_in_row in walls_array_x[0].size():
		for wall_section in walls_array_x[0][cell_in_row].size():
			if not walls_array_x[0][cell_in_row][wall_section] == 0:
				pass
			else:
				# Calculate x-offset of foundation stairs,
				# based on position of first wall section.
				# Translate foundation stairs from that point, 
				# using wall section length as multiplier.
				var foundation_stairs_instance: Node3D = foundation_stairs.instantiate()
				foundation_stairs_instance.position.z += foundation_origin_to_edge_metres
				foundation_stairs_instance.position.x += \
						first_wall_section_in_array_x_top_row_position.x + \
						(cell_in_row * floorplan_cell_size_metres) + \
						(wall_section * wall_length_metres) + \
						offset_due_wall_section_origin
				foundation_stairs_instance.rotation.y += right_angle_rotation * 2
				add_child(foundation_stairs_instance)

## Calculate positions of stairs on bottom row (array_x).
func instantiate_stairs_on_bottom_row() -> void:
	# Calculate position of first wall in bottom row, whether it's null or not.
	var first_wall_section_in_array_x_bottom_row_position: Vector3
	first_wall_section_in_array_x_bottom_row_position.x -= floorplan_cell_size_metres
	first_wall_section_in_array_x_bottom_row_position.z -= floorplan_cell_size_metres
	first_wall_section_in_array_x_bottom_row_position.x -= wall_length_metres
	first_wall_section_in_array_x_bottom_row_position.z -= wall_length_metres
	
	var offset_due_wall_section_origin: float = wall_length_metres / 2
	var bottom_row_in_array_x: int = walls_array_x.size() - 1
	for cell_in_row in walls_array_x[bottom_row_in_array_x].size():
		for wall_section in walls_array_x[bottom_row_in_array_x][cell_in_row].size():
			if not walls_array_x[bottom_row_in_array_x][cell_in_row][wall_section] == 0:
				pass
			else:
				# Calculate x-offset of foundation stairs,
				# based on position of first wall section.
				# Translate foundation stairs from that point,
				# using wall section length as multiplier.
				var foundation_stairs_instance: Node3D = foundation_stairs.instantiate()
				foundation_stairs_instance.position.z -= foundation_origin_to_edge_metres
				
				# Switch wall_section from 0 to 1, or vice versa, 
				# as from the outside perspective of the bottom wall, 
				# the wall section indeces are mirrored.
				wall_section = (wall_section + 1) % 2
				
				foundation_stairs_instance.position.x += \
						first_wall_section_in_array_x_bottom_row_position.x + \
						(cell_in_row * floorplan_cell_size_metres) + \
						(wall_section * wall_length_metres) + \
						offset_due_wall_section_origin
				foundation_stairs_instance.rotation.y += 0
				add_child(foundation_stairs_instance)

## Calculate positions of stairs on left row (array_y).
func instantiate_stairs_on_left_row() -> void:
	# Calculate position of first wall in left row, whether it's null or not.
	var first_wall_section_in_array_y_left_row_position: Vector3
	first_wall_section_in_array_y_left_row_position.x += floorplan_cell_size_metres
	first_wall_section_in_array_y_left_row_position.z += floorplan_cell_size_metres
	first_wall_section_in_array_y_left_row_position.x += wall_length_metres
	first_wall_section_in_array_y_left_row_position.z += wall_length_metres
	
	var offset_due_wall_section_origin: float = wall_length_metres / 2
	for row in walls_array_y.size():
		for wall_section in number_of_sections_per_wall:
			if not walls_array_y[row][0][wall_section] == 0:
				pass
			else:
				# Calculate x-offset of foundation stairs,
				# based on position of first wall section.
				# Translate foundation stairs from that point,
				# using wall section length as multiplier.
				var foundation_stairs_instance: Node3D = foundation_stairs.instantiate()
				foundation_stairs_instance.position.x -= foundation_origin_to_edge_metres
				
				# Switch wall_section from 0 to 1, or vice versa, 
				# as from the outside perspective of the left wall, 
				# the wall section indeces are mirrored.
				wall_section = (wall_section + 1) % 2
				
				foundation_stairs_instance.position.z += \
						first_wall_section_in_array_y_left_row_position.z - \
						(row * floorplan_cell_size_metres) - \
						(wall_section * wall_length_metres) - \
						offset_due_wall_section_origin
				foundation_stairs_instance.rotation.y += right_angle_rotation
				add_child(foundation_stairs_instance)


## Calculate positions of stairs on right row (array_y).
func instantiate_stairs_on_right_row() -> void:
	# Calculate position of first wall in right row, whether it's null or not.
	var first_wall_section_in_array_y_left_row_position: Vector3
	first_wall_section_in_array_y_left_row_position.x += floorplan_cell_size_metres
	first_wall_section_in_array_y_left_row_position.z -= floorplan_cell_size_metres
	first_wall_section_in_array_y_left_row_position.x += wall_length_metres
	first_wall_section_in_array_y_left_row_position.z -= wall_length_metres
	
	var offset_due_wall_section_origin: float = wall_length_metres / 2
	var last_index_in_row: int = walls_array_y[0].size() - 1
	
	for row in walls_array_y.size():
		for wall_section in number_of_sections_per_wall:
			if not walls_array_y[row][last_index_in_row][wall_section] == 0:
				pass
			else:
				# Calculate x-offset of foundation stairs,
				# based on position of first wall section.
				# Translate foundation stairs from that point,
				# using wall section length as multiplier.
				var foundation_stairs_instance: Node3D = foundation_stairs.instantiate()
				foundation_stairs_instance.position.x += foundation_origin_to_edge_metres
				
				# Switch wall_section from 0 to 1, or vice versa, 
				# as from the outside perspective of the left wall, 
				# the wall section indeces are mirrored.
				#wall_section = (wall_section + 1) % 2
				
				foundation_stairs_instance.position.z -= \
						first_wall_section_in_array_y_left_row_position.z + \
						(row * floorplan_cell_size_metres) + \
						(wall_section * wall_length_metres) + \
						offset_due_wall_section_origin
				foundation_stairs_instance.rotation.y += right_angle_rotation * 3
				add_child(foundation_stairs_instance)
