extends Node3D
@export var wall_section_height_metres : float = 3
var right_angle_rotation : float = PI

var wall_section_local_positions : Array[Vector3] = [
	Vector3(4, 0, -4),
	Vector3(0, 0, -4),
	Vector3(-4, 0, -4),
	Vector3(-4, 0, 0),
	Vector3(-4, 0, 4),
	Vector3(0, 0, 4),
	Vector3(4, 0, 4),
	Vector3(4, 0, 0),
	]
	
var building_component_types_dictionary = {
	"floor_stairs_hole" : preload("res://Scenes/Buildings/Building001/001floor_stairs_hole.tscn"),
	"wall_interior" : preload("res://Scenes/Buildings/Building001/001wall_interior.tscn"),
	"stairs_ground_floor" : preload("res://Scenes/Buildings/Building001/001stairs_002_ground_floor.tscn"),
	"stairs_001" : preload("res://Scenes/Buildings/Building001/001stairs_001.tscn"),
	"stairs_002" : preload("res://Scenes/Buildings/Building001/001stairs_002.tscn"),
	"floor_roof" : preload("res://Scenes/Buildings/Building001/001floor_roof.tscn"),
	"floor_top_001" : preload("res://Scenes/Buildings/Building001/001floor_top_001.tscn"),
	"floor_top_002" : preload("res://Scenes/Buildings/Building001/001floor_top_002.tscn"),
	"foundation" : preload("res://Scenes/Buildings/Building001/001foundation.tscn"),
	"wall_blank" : preload("res://Scenes/Buildings/Building001/001wall_blank.tscn"),
	"wall_two_doors" : preload("res://Scenes/Buildings/Building001/001wall_two_doors.tscn"),
	"wall_windows_001" : preload("res://Scenes/Buildings/Building001/001wall_windows_001.tscn"),
	"wall_windows_002" : preload("res://Scenes/Buildings/Building001/001wall_windows_002.tscn"),
	"wall_windows_003" : preload("res://Scenes/Buildings/Building001/001wall_windows_003.tscn"),
	"wall_windows_doors" : preload("res://Scenes/Buildings/Building001/001wall_windows_doors.tscn"),
	"floor_top_wall_blocker_001" : preload("res://Scenes/Buildings/Building001/001floor_top_wall_blocker_001.tscn"),
	"floor_top_wall_blocker_002" : preload("res://Scenes/Buildings/Building001/001floor_top_wall_blocker_002.tscn"),
	}
# Determine which side of foundation will have outer steps
var rotate_foundation = randi_range(0, 3)

func _ready():
	build_foundation_and_steps()
	
	# Put in the first story, with a door aligned to the steps
	build_street_storey()
	
	var number_of_storeys = randi_range(1, 7)
	build_storeys(number_of_storeys)
	
	build_floors_and_roof(number_of_storeys)
	
	build_internal_stairs(number_of_storeys)
	
	build_internal_walls(number_of_storeys)
	
	build_top_floor_stairwell(number_of_storeys)
	
	build_top_floor(number_of_storeys)
	
	build_roof(number_of_storeys)
	
	print("local coords: ", position, "; global coords: ", global_position)
	
func build_foundation_and_steps():
	var foundation = building_component_types_dictionary["foundation"]
	var foundation_instance = foundation.instantiate()
	foundation_instance.position.y = -10
	foundation_instance.rotation.y += deg_to_rad(90 * rotate_foundation)
	add_child(foundation_instance)

func build_street_storey():
	for wall_section_count in wall_section_local_positions.size():
		var wall_type_selection = randi_range(1, 5)
		var wall_selection = null # …so that wall_selection can be used outside of the if-elif-else block
		if wall_type_selection == 1:
			wall_selection = building_component_types_dictionary["wall_blank"]
		elif wall_type_selection == 2:
			wall_selection = building_component_types_dictionary["wall_windows_001"]
		elif wall_type_selection == 3:
			wall_selection = building_component_types_dictionary["wall_windows_002"]
		elif wall_type_selection == 4:
			wall_selection = building_component_types_dictionary["wall_windows_003"]
		else:
			wall_selection = building_component_types_dictionary["wall_two_doors"]
		
		# Over-ride the choice of wall type if the current section coincides with the external stairs
		if rotate_foundation == 0 and wall_section_count == 1:
			wall_selection = building_component_types_dictionary["wall_windows_doors"]
		elif rotate_foundation == 1 and wall_section_count == 3:
			wall_selection = building_component_types_dictionary["wall_windows_doors"]
		elif rotate_foundation == 2 and wall_section_count == 5:
			wall_selection = building_component_types_dictionary["wall_windows_doors"]
		elif rotate_foundation == 3 and wall_section_count == 7:
			wall_selection = building_component_types_dictionary["wall_windows_doors"]
		else:
			pass
		
		var wall_selectioninstance = wall_selection.instantiate() # instantiate
		wall_selectioninstance.position = wall_section_local_positions[wall_section_count]
		
		if wall_section_count <= 1: # array indeces start at 0, don't forget!
			wall_selectioninstance.rotation.y = 0
		# rotate the two wall sections of the second side
		elif wall_section_count <= 3:
			wall_selectioninstance.rotation.y += right_angle_rotation * 0.5
		# rotate the two wall sections of the third side
		elif wall_section_count <= 5:
			wall_selectioninstance.rotation.y += right_angle_rotation * 1
		# rotate the two wall sections of the fourth side
		elif wall_section_count >= 6:
			wall_selectioninstance.rotation.y += right_angle_rotation * 1.5
		# safety measure to catch potential loop bugs
		else:
			pass
			
		add_child(wall_selectioninstance) # insert in scene tree
		
func build_storeys(number_of_storeys):
	for storey in number_of_storeys:
		
		# Calculate height on the y-axis for the current storey
		var storey_base_height_metres = (storey + 1) * wall_section_height_metres # + 1 because of array indexing conventions

		# Randomise wall type selection
		var wall_type_selection = randi_range(1, 4)
		var wall_selection = null # …so that wall_selection can be used outside of the if-elif-else block
		if wall_type_selection == 1:
			wall_selection = building_component_types_dictionary["wall_blank"]
		elif wall_type_selection == 2:
			wall_selection = building_component_types_dictionary["wall_windows_001"]
		elif wall_type_selection == 3:
			wall_selection = building_component_types_dictionary["wall_windows_002"]
		else:
			wall_selection = building_component_types_dictionary["wall_windows_003"]
		
		# Instantiate wall section, based on type selected
		for wall_section_count in wall_section_local_positions.size():
			var wall_selectioninstance = wall_selection.instantiate()
			wall_selectioninstance.position = wall_section_local_positions[wall_section_count] # set coordinates based on wall section length and number of sections already placed
			wall_selectioninstance.position.y = storey_base_height_metres
			# rotate the two wall sections of the first side (technically redundant, here for readability)
			if wall_section_count <= 1: # array indeces start at 0, don't forget!
				wall_selectioninstance.rotation.y = 0
			
			# rotate the two wall sections of the second side
			elif wall_section_count <= 3:
				wall_selectioninstance.rotation.y += right_angle_rotation * 0.5
			
			# rotate the two wall sections of the third side
			elif wall_section_count <= 5:
				wall_selectioninstance.rotation.y += right_angle_rotation * 1
			
			# rotate the two wall sections of the fourth side
			elif wall_section_count >= 6:
				wall_selectioninstance.rotation.y += right_angle_rotation * 1.5
			
			# safety measure to catch potential loop bugs
			else:
				pass
			
			add_child(wall_selectioninstance) # insert wall section in scene tree
	
func build_floors_and_roof(number_of_storeys):
	for storey in number_of_storeys -1:
		# Check to see if current storey is last in the stack and we need to place a roof rather than a floor
		var floor_roof = null		
		if storey == number_of_storeys:
			floor_roof = building_component_types_dictionary["floor_roof"]
		else:
			floor_roof = building_component_types_dictionary["floor_stairs_hole"]
		
		var floor_roof_instance = floor_roof.instantiate()
		var floor_height_metres = ((storey + 1) * wall_section_height_metres)
		floor_roof_instance.position.y = floor_height_metres
		add_child(floor_roof_instance)
		
func build_internal_walls(number_of_storeys):
	for storey in number_of_storeys:
		var wall_interior = building_component_types_dictionary["wall_interior"]
		var wall_interior_instance = wall_interior.instantiate()
		var floor_height_metres = storey * wall_section_height_metres
		wall_interior_instance.position.y = floor_height_metres
		add_child(wall_interior_instance)

func build_internal_stairs(number_of_storeys):
	for storey in number_of_storeys:
		var internal_stairs = null
		if storey ==  0:
			internal_stairs = building_component_types_dictionary["stairs_ground_floor"]
		if storey > 0 && storey % 2 == 0:
			internal_stairs = building_component_types_dictionary["stairs_002"]
		if storey > 0 && storey % 2 != 0:
			internal_stairs = building_component_types_dictionary["stairs_001"]
		else:
			pass
		
		var internal_stairs_instance = internal_stairs.instantiate()
		var floor_height_metres = storey * wall_section_height_metres
		internal_stairs_instance.position.y = floor_height_metres
		add_child(internal_stairs_instance)
	
func build_top_floor_stairwell(number_of_storeys):
	var top_floor_stairwell = null
	if number_of_storeys % 2 == 0:
		top_floor_stairwell = building_component_types_dictionary["floor_top_wall_blocker_001"]
	
	else:
		top_floor_stairwell = building_component_types_dictionary["floor_top_wall_blocker_002"]
		
	var top_floor_stairwell_instance = top_floor_stairwell.instantiate()
	top_floor_stairwell_instance.position.y = number_of_storeys * wall_section_height_metres
	add_child(top_floor_stairwell_instance)
	
func build_top_floor(number_of_storeys):
	var top_floor = null
	if number_of_storeys % 2 == 0:
		top_floor = building_component_types_dictionary["floor_top_001"]
	else:
		top_floor = building_component_types_dictionary["floor_top_002"]
	var top_floor_instance = top_floor.instantiate()
	var top_floor_height_metres = number_of_storeys * wall_section_height_metres
	top_floor_instance.position.y = top_floor_height_metres
	add_child(top_floor_instance)

func build_roof(number_of_storeys):
	var floor_roof = building_component_types_dictionary["floor_roof"]
	var floor_roof_instance = floor_roof.instantiate()
	var floor_height_metres = ((number_of_storeys + 1) * wall_section_height_metres)
	floor_roof_instance.position.y = floor_height_metres
	add_child(floor_roof_instance)

func _process(_delta):
	pass
