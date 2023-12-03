extends Node3D

@export var max_number_buildings_on_x_axis : int = 20
@export var max_number_buildings_on_z_axis : int = 20
@export var distance_between_buildings_metres : int = 20
@export var inherited_offset_correction : int = -220

# Toggle to stop the physics process fuction repeating the building placement task
var rays_fired : int = 0

var building001 = preload("res://Scenes/Buildings/Building001.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _physics_process(_delta):
	if rays_fired == 0:
		for count_building_on_x_axis in max_number_buildings_on_x_axis:
			for count_building_on_z_axis in max_number_buildings_on_z_axis:
				var x_location : float = ((0 - (max_number_buildings_on_x_axis / 2.0) + count_building_on_x_axis) * distance_between_buildings_metres) - inherited_offset_correction
				var z_location : float = ((0 - (max_number_buildings_on_z_axis / 2.0) + count_building_on_z_axis) * distance_between_buildings_metres) - inherited_offset_correction
				
				# Get access to Godot's space / physics wonders
				var space_state = get_world_3d().get_direct_space_state()
				
				# Set up the start and end points of the raycast
				var params = PhysicsRayQueryParameters3D.new()
				params.from = Vector3(x_location, 20, z_location)
				params.to = Vector3(x_location, -20, z_location)
				params.exclude = []
				
				# Fire the ray!
				var collision = space_state.intersect_ray(params)
			
				
				# Instantiate building at point of ray intersection with ground
				var building_instance = building001.instantiate()
				building_instance.position.x = x_location
				building_instance.position.y = collision.position.y
				building_instance.position.z = z_location
				add_sibling(building_instance)
		
		
		
		# Stop this from happening again
		rays_fired += 1
	
	else:
		pass
