@icon("res://images/Icons/building_icon.png")

extends Node

@export_group("Plug-in nodes")
## Plug in root / MainSequence node
@export var main_sequence_node: Node
@export var data_node: Node

## Stores distance in metres each wall section should be translated
## as the result of the 'parent' cell's position.
var cell_offsets_metres_array: Array = []
var floorplan_grid_size: int
## Stores floorplan layout as a grid.
var floorplan: Array = []
var floorplan_cell_size_metres: float
var number_of_sections_per_wall: int
var wall_height_metres: float
var wall_length_metres: float
## Stores distance in metres each wall section should be translated
## relative to 'parent' cell.
var wall_section_local_positions_metres_array: Array = []
## Stores the floorplan's cells' surrounding walls on the x-axis of the grid.
var walls_array_x: Array = []
## Stores the floorplan's cells' surrounding walls on the y-axis of the grid.
var walls_array_y: Array = []
var wall_pillar: PackedScene


func sequence(storey) -> void:
	get_data()
	instantiate_wall_pillar_sequence(storey)


func get_data() -> void:
	cell_offsets_metres_array = data_node.cell_offsets_metres_array
	floorplan = data_node.floorplan
	floorplan_grid_size = data_node.floorplan_grid_size
	floorplan_cell_size_metres = data_node.floorplan_cell_size_metres
	number_of_sections_per_wall = data_node.number_of_sections_per_wall
	wall_length_metres = data_node.wall_length_metres
	wall_height_metres = data_node.wall_height_metres
	wall_section_local_positions_metres_array = \
			data_node.wall_section_local_positions_metres_array
	walls_array_x = data_node.walls_array_x
	walls_array_y = data_node.walls_array_y
	wall_pillar = Building002Assets.wall_pillar

func instantiate_wall_pillar_sequence(storey) -> void:
	print("cell_offsets_metres_array = ", cell_offsets_metres_array)
	# Cycle through array_x, placing a pillar at each wall join.
	for row in walls_array_x.size():
		for cell_in_row in walls_array_x[row].size():
			for wall_section in walls_array_x[row][cell_in_row].size():
				if walls_array_x[row][cell_in_row][wall_section] == null:
					pass
				else:
					instantiate_wall_pillar(
						storey,
						row,
						cell_in_row,
						wall_section,
						)

func instantiate_wall_pillar(
	storey,
	row,
	cell_in_row,
	wall_section
	) -> void:
	var wall_pillar_instance: Node3D = wall_pillar.instantiate()
	# Add translation due to storey.
	wall_pillar_instance.position.y += storey * wall_height_metres
	# Add translation due to cell, relative to floorplan centre.
	
	# Ignore the last row in in the walls array,
	# as its index is one larger than the cell offsets array.
	if row == walls_array_x[row].size():
		pass
	else:
		wall_pillar_instance.position += cell_offsets_metres_array[row][cell_in_row]
	
	# Add translation due to wall position, relative to cell centre.
	
	# Indeces for the +Z side (top of debug floorplan) wall sections are needed.
	# Skip the +X side ('left' side of debug floorplan)
	# by adding number of sectons per wall.
	var wall_section_in_cell_offsets_index: int = \
			wall_section + number_of_sections_per_wall
	
	wall_pillar_instance.position += \
			wall_section_local_positions_metres_array[wall_section_in_cell_offsets_index]
	
	add_child(wall_pillar_instance)
