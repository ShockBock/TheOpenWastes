extends Node3D

@export_range(0, 20) var max_number_buildings_on_x_axis : int = 12
@export_range(0, 20) var max_number_buildings_on_z_axis : int = 12
@export var distance_between_buildings_metres : int = 20
@export_range(0.0, 2.0, 0.01) var y_offset_metres : float = 1.0

signal buildings_complete

var building001 = preload("res://Scenes/buildings/building001.tscn")

func _on_main_sequence_place_buildings_signal():
	spawn_buildings_on_x_z_grid()
	_emit_buildings_complete.call_deferred()

func spawn_buildings_on_x_z_grid():
	for count_building_on_x_axis in max_number_buildings_on_x_axis:
		for count_building_on_z_axis in max_number_buildings_on_z_axis:
			locate_building_site_in_world_space(count_building_on_x_axis, count_building_on_z_axis)

func locate_building_site_in_world_space(count_building_on_x_axis, count_building_on_z_axis):
	var building_foundation_x : float = count_building_on_x_axis
	building_foundation_x -= (max_number_buildings_on_x_axis / 2.0)
	building_foundation_x *= distance_between_buildings_metres
	
	var building_foundation_z : float = count_building_on_z_axis
	building_foundation_z -= (max_number_buildings_on_z_axis / 2.0)
	building_foundation_z *= distance_between_buildings_metres
	
	locate_building_ground_elevation(building_foundation_x, building_foundation_z)
	
func locate_building_ground_elevation(building_foundation_x, building_foundation_z):
	# Get access to Godot's space / physics wonders
	var space_state = get_world_3d().get_direct_space_state()
	
	# Set up a raycast whose collision with the terrain will determine where to position building's height on y-axis
	var params = PhysicsRayQueryParameters3D.new()
	params.from = Vector3(building_foundation_x, 50, building_foundation_z)
	params.to = Vector3(building_foundation_x, -50, building_foundation_z)
	params.exclude = []
	
	# Fire the ray!
	var terrain_intersection = space_state.intersect_ray(params)
	var building_foundation_y = terrain_intersection.position.y + y_offset_metres
	
	instantiate_building(building_foundation_x, building_foundation_y, building_foundation_z)
	
func instantiate_building(building_foundation_x, building_foundation_y, building_foundation_z):
	var building_instance = building001.instantiate()
	building_instance.position.x = building_foundation_x
	building_instance.position.y = building_foundation_y
	building_instance.position.z = building_foundation_z
	add_child(building_instance)

func _emit_buildings_complete():
	emit_signal("buildings_complete")
