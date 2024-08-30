@icon("res://images/Icons/building_icon.png")

extends Node

## Receives arrays of randomly chosen wall sections
## and instantiates them in world space.

@export_group("Plug-in nodes")
## Plug in root / MainSequence node
@export var main_sequence_node: Node
@export var data_node: Node

var right_angle_rotation: float = PI / 2

## Stores distance in metres each wall section should be translated
## as the result of the 'parent' cell's position.
var cell_offsets_metres_array: Array = []
var floorplan_grid_size: int
## Stores floorplan layout as a grid.
var floorplan: Array = []
var floorplan_cell_size_metres: float
var wall_height_metres: float
## Stores distance in metres each wall section should be translated
## relative to 'parent' cell.
var wall_section_local_positions_metres_array: Array = []
## Stores the floorplan's cells' surrounding walls on the x-axis of the grid.
var walls_array_x: Array = []
## Stores the floorplan's cells' surrounding walls on the y-axis of the grid.
var walls_array_y: Array = []

func sequence(storey: int) -> void:
	get_grid_properties_from_data_node()
	if storey == 1:
		# Ground floor (index 0) has already been built; 
		# remove external doors from walls arrays.
		replace_door_assets()
	instantiate_walls_sequence(storey)


func get_grid_properties_from_data_node() -> void:
	cell_offsets_metres_array = data_node.cell_offsets_metres_array
	floorplan = data_node.floorplan
	floorplan_grid_size = data_node.floorplan_grid_size
	floorplan_cell_size_metres = data_node.floorplan_cell_size_metres
	wall_height_metres = data_node.wall_height_metres
	wall_section_local_positions_metres_array = \
			data_node.wall_section_local_positions_metres_array
	walls_array_x = data_node.walls_array_x
	walls_array_y = data_node.walls_array_y


## Makes sure external doors do not manifest above ground level
## by replacing indeces containing them in the wall arrays with door-less wall assets.
func replace_door_assets() -> void:
	for row in walls_array_x.size():
		for cell_in_row in walls_array_x[row].size():
			for wall_section in walls_array_x[row][cell_in_row].size():
				#print("wall_section in walls_array_x[row][cell_in_row].size() = ", walls_array_x[row][cell_in_row][wall_section])
				if walls_array_x[row][cell_in_row][wall_section] == null:
					pass
				elif walls_array_x[row][cell_in_row][wall_section] == 0:
					walls_array_x[row][cell_in_row][wall_section] = \
							randi_range(1, Building002Assets.walls_asset_array.size() - 1)
				else:
					pass
	
	for row in walls_array_y.size():
		for cell_in_row in walls_array_y[row].size():
			for wall_section in walls_array_y[row][cell_in_row].size():
				if walls_array_y[row][cell_in_row][wall_section] == null:
					pass
				elif walls_array_y[row][cell_in_row][wall_section] == 0:
					walls_array_y[row][cell_in_row][wall_section] = \
							randi_range(1, Building002Assets.walls_asset_array.size() - 1)
				else:
					pass
	data_node.walls_array_x = walls_array_x
	data_node.walls_array_y = walls_array_y


func instantiate_walls_sequence(storey: int) -> void:
	# For each row in the floorplan...
	for row in range(floorplan_grid_size):
		# For each cell in that row...
		for cell_in_row in range(floorplan_grid_size):
			# For each wall section of that cell...
			for wall_section_count in \
					(wall_section_local_positions_metres_array.size()):
				instantiate_walls(
					storey,
					row,
					cell_in_row,
					wall_section_count,
					)


func instantiate_walls(
	storey: int,
	row: int,
	cell_in_row: int,
	wall_section_count: int
	):
	
	## Used to store instantiated wall sections.
	var wall_section_instance: Node3D
	
	# For the wall sections on the left of the cell...
	if walls_array_y[row][cell_in_row][wall_section_count % 2] == null:
		pass
	elif wall_section_count < data_node.number_of_sections_per_wall:
		var wall_section_selection = \
				walls_array_y[row][cell_in_row][wall_section_count % 2]
		wall_section_instance = \
				Building002Assets.walls_asset_array[wall_section_selection].instantiate()
		# Add wall section's local translation relative to 'parent' cell.
		wall_section_instance.position = \
				wall_section_local_positions_metres_array[wall_section_count]
		# Add the cell's translation relative to overall floorplan.
		wall_section_instance.position += cell_offsets_metres_array[row][cell_in_row]
		# Add the section's vertical translation due to its storey.
		wall_section_instance.position.y += storey * wall_height_metres
		# Add the section's rotation due to the wall of which it forms part.
		wall_section_instance.rotation.y = right_angle_rotation
		add_child(wall_section_instance)
	else:
		pass
	
	# For the wall sections on the top of the cell...
	if walls_array_x[row][cell_in_row][wall_section_count % 2] == null:
		pass
	elif (
		wall_section_count >= data_node.number_of_sections_per_wall
		and wall_section_count < (data_node.number_of_sections_per_wall * 2)
		):
		var wall_section_selection = walls_array_x[row][cell_in_row][wall_section_count % 2]
		wall_section_instance = Building002Assets.walls_asset_array[wall_section_selection].instantiate()
		# Add wall section's local translation relative to 'parent' cell.
		wall_section_instance.position = wall_section_local_positions_metres_array[wall_section_count]
		# Add the cell's translation relative to overall floorplan.
		wall_section_instance.position += cell_offsets_metres_array[row][cell_in_row]
		# Add the section's vertical translation due to its storey.
		wall_section_instance.position.y += storey * wall_height_metres
		# Add the section's rotation due to the wall of which it forms part.
		wall_section_instance.rotation.y = right_angle_rotation * 2
		add_child(wall_section_instance)
	else:
		pass
	
	# If the current cell is on the right hand side of floorplan
	# add wall to the right.
	if walls_array_y[row][cell_in_row + 1][wall_section_count % 2] == null:
		pass # current array entry is empty; proceed no further.
	elif (
		wall_section_count >= (data_node.number_of_sections_per_wall * 2)
		and wall_section_count < (data_node.number_of_sections_per_wall * 3)
		and cell_in_row == (floorplan_grid_size - 1)
		):
		var wall_section_selection = walls_array_y[row][cell_in_row + 1][wall_section_count % 2]
		wall_section_instance = Building002Assets.walls_asset_array[wall_section_selection].instantiate()
		# Add wall section's local translation relative to 'parent' cell.
		wall_section_instance.position = wall_section_local_positions_metres_array[wall_section_count]
		# Add the cell's translation relative to overall floorplan.
		wall_section_instance.position += cell_offsets_metres_array[row][cell_in_row]
		# Add the section's vertical translation due to its storey.
		wall_section_instance.position.y += storey * wall_height_metres
		# Add the section's rotation due to the wall of which it forms part.
		wall_section_instance.rotation.y = right_angle_rotation * 3
		add_child(wall_section_instance)
	else:
		pass
	
	# If the current cell is on the bottom of floorplan add wall below.
	if walls_array_x[row + 1][cell_in_row][wall_section_count % 2] == null:
		pass
	elif (
		wall_section_count >= (data_node.number_of_sections_per_wall * 3)
		and row == (floorplan_grid_size - 1)
		):
		var wall_section_selection = walls_array_x[row + 1][cell_in_row][wall_section_count % 2]
		wall_section_instance = Building002Assets.walls_asset_array[wall_section_selection].instantiate()
		# Add wall section's local translation relative to 'parent' cell.
		wall_section_instance.position = wall_section_local_positions_metres_array[wall_section_count]
		# Add the cell's translation relative to overall floorplan.
		wall_section_instance.position += cell_offsets_metres_array[row][cell_in_row]
		# Add the section's vertical translation due to its storey.
		wall_section_instance.position.y += storey * wall_height_metres
		# Add the section's rotation due to the wall of which it forms part.
		wall_section_instance.rotation.y = 0
		add_child(wall_section_instance)
	else:
		pass
