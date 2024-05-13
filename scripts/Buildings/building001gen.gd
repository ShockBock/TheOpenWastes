extends Node3D
@export var wall_section_height_metres : float = 3
@export var roof_intact_global_probability : float = 0.25

var number_of_storeys = randi_range(1, 7)
var roof_intact_local : bool = randf() < roof_intact_global_probability
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
	"wall_blank_broken" : preload("res://Scenes/Buildings/Building001/001wall_blank_broken.tscn"),
	"wall_two_doors" : preload("res://Scenes/Buildings/Building001/001wall_two_doors.tscn"),
	"wall_windows_001" : preload("res://Scenes/Buildings/Building001/001wall_windows_001.tscn"),
	"wall_windows_001_broken" : preload("res://Scenes/Buildings/Building001/001wall_windows_001_broken.tscn"),
	"wall_windows_002" : preload("res://Scenes/Buildings/Building001/001wall_windows_002.tscn"),
	"wall_windows_002_broken" : preload("res://Scenes/Buildings/Building001/001wall_windows_002_broken.tscn"),
	"wall_windows_003" : preload("res://Scenes/Buildings/Building001/001wall_windows_003.tscn"),
	"wall_windows_003_broken" : preload("res://Scenes/Buildings/Building001/001wall_windows_003_broken.tscn"),
	"wall_windows_doors" : preload("res://Scenes/Buildings/Building001/001wall_windows_doors.tscn"),
	"floor_top_wall_blocker_001" : preload("res://Scenes/Buildings/Building001/001floor_top_wall_blocker_001.tscn"),
	"floor_top_wall_blocker_001_broken" : preload("res://Scenes/Buildings/Building001/001floor_top_wall_blocker_001_broken.tscn"),
	"floor_top_wall_blocker_002" : preload("res://Scenes/Buildings/Building001/001floor_top_wall_blocker_002.tscn"),
	"floor_top_wall_blocker_002_broken" : preload("res://Scenes/Buildings/Building001/001floor_top_wall_blocker_002_broken.tscn"),
	"rubble_wall_blank" : preload("res://Scenes/Buildings/Building001/001rubble_wall_blank.tscn"),
	"rubble_windows_001" : preload("res://Scenes/Buildings/Building001/001rubble_windows_001.tscn"),
	"rubble_windows_002" : preload("res://Scenes/Buildings/Building001/001rubble_windows_002.tscn"),
	"rubble_windows_003" : preload("res://Scenes/Buildings/Building001/001rubble_windows_003.tscn")
	}
# Determine which side of foundation will have outer steps
var rotate_foundation = randi_range(0, 3)

func _ready():
	build_foundation_and_steps()
	
	build_ground_level_external_walls()
	
	build_remaining_external_walls()
	
	build_floors()
	
	build_internal_stairs()
	
	build_internal_walls()
	
	choose_then_build_top_floor_stairwell()
	
	build_top_floor()
	
	build_roof()
	
	# print("local coords: ", position, "; global coords: ", global_position)
	
func build_foundation_and_steps():
	var foundation = building_component_types_dictionary["foundation"]
	var foundation_instance = foundation.instantiate()
	foundation_instance.position.y = -10
	foundation_instance.rotation.y += deg_to_rad(90 * rotate_foundation)
	add_child(foundation_instance)

func build_ground_level_external_walls():
	for wall_section_count in wall_section_local_positions.size():
		var wall_type_selection = randi_range(1, 5)
		var wall_selection = null
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

func build_remaining_external_walls():
		for storey in number_of_storeys:
			if storey == (number_of_storeys - 1):
				build_top_storey(storey)
			else:
				build_intact_storey(storey)

func build_intact_storey(storey):
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

func build_top_storey(storey):
	if roof_intact_local == true:
		build_intact_storey(storey)
	else:
		# Calculate height on the y-axis for the current storey
		var storey_base_height_metres = (storey + 1) * wall_section_height_metres # + 1 because of array indexing conventions

		# Randomise wall type selection
		var wall_type_selection = randi_range(1, 4)
		var wall_selection = null # …so that wall_selection can be used outside of the if-elif-else block
		if wall_type_selection == 1:
			wall_selection = building_component_types_dictionary["wall_blank_broken"]
		elif wall_type_selection == 2:
			wall_selection = building_component_types_dictionary["wall_windows_001_broken"]
		elif wall_type_selection == 3:
			wall_selection = building_component_types_dictionary["wall_windows_002_broken"]
		else:
			wall_selection = building_component_types_dictionary["wall_windows_003_broken"]
		
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
	
func build_floors():
	for storey in number_of_storeys -1:
		var floor_roof = building_component_types_dictionary["floor_stairs_hole"]
		var floor_roof_instance = floor_roof.instantiate()
		var floor_height_metres = ((storey + 1) * wall_section_height_metres)
		floor_roof_instance.position.y = floor_height_metres
		add_child(floor_roof_instance)

func build_roof():
	if roof_intact_local == false:
		pass
	else:
		var floor_roof = building_component_types_dictionary["floor_roof"]
		var floor_roof_instance = floor_roof.instantiate()
		var floor_height_metres = ((number_of_storeys + 1) * wall_section_height_metres)
		floor_roof_instance.position.y = floor_height_metres
		add_child(floor_roof_instance)
	
func build_internal_walls():
	for storey in number_of_storeys:
		var wall_interior = building_component_types_dictionary["wall_interior"]
		var wall_interior_instance = wall_interior.instantiate()
		var floor_height_metres = storey * wall_section_height_metres
		wall_interior_instance.position.y = floor_height_metres
		add_child(wall_interior_instance)

func build_internal_stairs():
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

func choose_then_build_top_floor_stairwell():
	if roof_intact_local == false:
		build_top_floor_stairwell_broken()
	else:
		build_top_floor_stairwell_intact()

func build_top_floor_stairwell_broken():
	var top_floor_stairwell = null
	if number_of_storeys % 2 == 0:
		top_floor_stairwell = building_component_types_dictionary["floor_top_wall_blocker_001_broken"]
	else:
		top_floor_stairwell = building_component_types_dictionary["floor_top_wall_blocker_002_broken"]
		
	var top_floor_stairwell_instance = top_floor_stairwell.instantiate()
	top_floor_stairwell_instance.position.y = number_of_storeys * wall_section_height_metres
	add_child(top_floor_stairwell_instance)

func build_top_floor_stairwell_intact():
	var top_floor_stairwell = null
	if number_of_storeys % 2 == 0:
		top_floor_stairwell = building_component_types_dictionary["floor_top_wall_blocker_001_broken"]
	else:
		top_floor_stairwell = building_component_types_dictionary["floor_top_wall_blocker_002_broken"]
		
	var top_floor_stairwell_instance = top_floor_stairwell.instantiate()
	top_floor_stairwell_instance.position.y = number_of_storeys * wall_section_height_metres
	add_child(top_floor_stairwell_instance)

func build_top_floor():
	var top_floor = null
	if number_of_storeys % 2 == 0:
		top_floor = building_component_types_dictionary["floor_top_001"]
	else:
		top_floor = building_component_types_dictionary["floor_top_002"]
	var top_floor_instance = top_floor.instantiate()
	var top_floor_height_metres = number_of_storeys * wall_section_height_metres
	top_floor_instance.position.y = top_floor_height_metres
	add_child(top_floor_instance)
	

func _process(_delta):
	pass
