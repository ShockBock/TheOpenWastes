@icon("res://images/Icons/building_icon.png")

extends Node

## Receives array of randomly chosen wall sections
## and instantiates them in world space.

enum CellState { EMPTY, OCCUPIED }

@export_group("Plug-in nodes")
## Plug in root / MainSequence node
@export var main_sequence_node: Node
@export var data_node: Node

var grid_size: int
var max_empty_cells: int
var right_angle_rotation: float = PI / 2

## Stores floorplan layout as a grid.
var floorplan: Array = []
## Stores the floorplan's cell's surrounding walls on the x-axis of the grid.
var walls_array_x: Array = []
## Stores the floorplan's cell's surrounding walls on the x-axis of the grid.
var walls_array_y: Array = []
var floorplan_cell_size_metres: float

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
## Stores distance in metres each wall section should be translated
## as the result of the 'parent' cell's position.
var cell_offsets_metres_array: Array = []


func sequence() -> void:
	get_grid_properties_from_data_node()
	calculate_cell_offset_array()
	instantiate_walls_sequence()
	DEBUG_print_grid()


func get_grid_properties_from_data_node() -> void:
	grid_size = data_node.grid_size
	max_empty_cells = data_node.max_empty_cells
	floorplan_cell_size_metres = data_node.floorplan_cell_size_metres


## Works out the (x, y) co-ordinates in metres by which to translate
## each cell's wall sections in world space
## and stores it in an array of dimensions equal to floorplan.
func calculate_cell_offset_array() -> void:
	## Works out the midpoint of one axis of the floorplan.
	## Subtracting the axis midpoint of the grid from each cell can be used to
	## 'normalise' the grid, so that the middle cell takes on (0, 0) co-ordinates.
	var floorplan_axis_midpoint = (floorplan.size() - 1) / 2.0
	
	# Works out the exact translation based on cell location for each cell
	# and stores it in an array.
	for row in range(grid_size):
		cell_offsets_metres_array.append([])
		for cell in range(grid_size):
			var cell_offset_metres: Vector3
			cell_offset_metres.x = (
				((cell - floorplan_axis_midpoint) * floorplan_cell_size_metres)
				)
			cell_offset_metres.y = 0
			cell_offset_metres.z = (
				((floorplan_axis_midpoint - row) * floorplan_cell_size_metres)
				)
			cell_offsets_metres_array[row].append(cell_offset_metres)


func instantiate_walls_sequence() -> void:
	var wall_section_instance
	# For each row in the floorplan...
	for row in range(grid_size):
		# For each cell in that row...
		for cell in range(grid_size):
			# For the left and top sides of the cells (hence half total array size)...
			for wall_section_count in \
					(wall_section_local_positions_metres_array.size() / 2):
				
				# For the wall sections on the left of the cell...
				if walls_array_y[row][cell][wall_section_count % 2] == null:
					pass
				elif wall_section_count == 0 or wall_section_count == 1:
					var wall_section_selection = walls_array_y[row][cell][wall_section_count % 2]
					wall_section_instance = data_node.walls_component_array[wall_section_selection].instantiate()
					# Add wall section's local translation relative to 'parent' cell.
					wall_section_instance.position = wall_section_local_positions_metres_array[wall_section_count]
					# Add the cell's translation relative to overall floorplan.
					wall_section_instance.position += cell_offsets_metres_array[row][cell]
					wall_section_instance.rotation.y = right_angle_rotation
					add_child(wall_section_instance)
				else:
					pass
				
				# For the wall sections on the top of the cell...
				if walls_array_x[row][cell][wall_section_count % 2] == null:
					pass
				elif wall_section_count == 2 or wall_section_count == 3:
					var wall_section_selection = walls_array_x[row][cell][wall_section_count % 2]
					wall_section_instance = data_node.walls_component_array[wall_section_selection].instantiate()
					# Add wall section's local translation relative to 'parent' cell.
					wall_section_instance.position = wall_section_local_positions_metres_array[wall_section_count]
					# Add the cell's translation relative to overall floorplan.
					wall_section_instance.position += cell_offsets_metres_array[row][cell]
					wall_section_instance.rotation.y = right_angle_rotation * 2
					add_child(wall_section_instance)
				else:
					pass
				
			# If the current cell is on the right hand side of floorplan
			# add wall to the right.
			if row == (grid_size - 1):
				# Section from only one wall out of five is needed, hence / 4
				for wall_section_count in \
					(wall_section_local_positions_metres_array.size() / 4):
					var wall_section_selection = walls_array_y[row][cell][wall_section_count % 2]
			# If the current cell is on the bottom of floorplan add wall below.
			if cell == (grid_size - 1):
				pass



func instantiate_walls_left_and_top() -> void:
	pass


func instantiate_walls_right_and_bottom() -> void:
	pass


func DEBUG_print_grid():
	print("Basic floorplan:")
	for row in range(grid_size):
		var line: String = ""
		for cell in range(grid_size):
			if floorplan[row][cell] == CellState.OCCUPIED:
				line += "[O] "
			else:
				line += "[ ] "
		print(line)
	print()
	print("Wall arrays:")
	print("Array x:")
	for row in walls_array_x.size():
		print(walls_array_x[row])
	print("Array y:")
	for cell in walls_array_y.size():
		print(walls_array_y[cell])
	print()
	print("cell_offsets_metres_array")
	print(cell_offsets_metres_array[0])
	print(cell_offsets_metres_array[1])
	print(cell_offsets_metres_array[2])
