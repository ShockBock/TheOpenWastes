extends Node3D

## Places characters.
##
## Junk code with many coding sins like magic numbers etc.
## Temporary and will be superceded with something far superior.

var shotgun_monk:= preload("res://Scenes/npcs/shotgun_monk.tscn")
var player_character:= preload("res://Scenes/player.tscn")

func _on_main_sequence_spawn_characters_signal():
	var character = null
	var character_x_offset: float
	var character_y_offset: float
	var character_z_offset: float
	
	character = player_character
	character_x_offset = 8.0
	character_y_offset = 2.0
	character_z_offset = 8.0
	spawn_character_instance(character, character_x_offset, character_y_offset, character_z_offset)
	
	character = shotgun_monk
	character_x_offset = 8.5
	character_y_offset = 0.0
	character_z_offset = -8.5
	spawn_character_instance(character, character_x_offset, character_y_offset, character_z_offset)

func spawn_character_instance(character, character_x_offset, character_y_offset, character_z_offset):
	# Get access to Godot's space / physics wonders
	var space_state = get_world_3d().get_direct_space_state()
	
	# Set up a raycast whose collision with the terrain will determine where to position character's height on y-axis
	var params = PhysicsRayQueryParameters3D.new()
	params.from = Vector3(character_x_offset, 50, character_z_offset)
	params.to = Vector3(character_x_offset, -50, character_z_offset)
	params.exclude = []
	
	var terrain_intersection = space_state.intersect_ray(params)
	
	var character_instance = character.instantiate()
	
	character_instance.position.x = character_x_offset
	character_instance.position.y = terrain_intersection.position.y + character_y_offset
	character_instance.position.z = character_z_offset
	
	add_child(character_instance)




