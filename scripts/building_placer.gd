extends Node3D

@export var max_number_buildings_on_x_axis : int = 20
@export var max_number_buildings_on_z_axis : int = 20
@export var distance_between_buildings_metres : int = 20

var building001 = preload("res://Scenes/Buildings/Building001.tscn")

func _on_ditzy_terrain_landscape_complete():
	for count_building_on_x_axis in max_number_buildings_on_x_axis:
		for count_building_on_z_axis in max_number_buildings_on_z_axis:
			locate_building_in_world_space(count_building_on_x_axis, count_building_on_z_axis)

func locate_building_in_world_space(count_building_on_x_axis, count_building_on_z_axis):
	var x_location : float = count_building_on_x_axis
	x_location -= (max_number_buildings_on_x_axis / 2.0)
	x_location *= distance_between_buildings_metres
	
	var z_location : float = count_building_on_z_axis
	z_location -= (max_number_buildings_on_z_axis / 2.0)
	z_location *= distance_between_buildings_metres
	
	locate_building_ground_elevation(x_location, z_location)
	
func locate_building_ground_elevation(x_location, z_location):
	# Get access to Godot's space / physics wonders
	var space_state = get_world_3d().get_direct_space_state()
	
	# Set up a raycast whose collision with the terrain will determine where to position building's height on y-axis
	var params = PhysicsRayQueryParameters3D.new()
	params.from = Vector3(x_location, 50, z_location)
	params.to = Vector3(x_location, -50, z_location)
	params.exclude = []
	
	# Fire the ray!
	var y_location = space_state.intersect_ray(params)
	
	instantiate_building(x_location, y_location, z_location)
	
func instantiate_building(x_location, y_location, z_location):
	var building_instance = building001.instantiate()
	building_instance.position.x = x_location
	building_instance.position.y = y_location.position.y
	building_instance.position.z = z_location
	add_child(building_instance)
