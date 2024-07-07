extends Node
var projectile = preload("res://Scenes/Miscellaneous/projectile_tracer.tscn")

var facing_angles : Vector3
var direction : Vector3

@onready var player : CharacterBody3D = get_parent()
@onready var head : Node3D = $"../Head"
@onready var camera : Camera3D = $"../Head/Camera3D"

# Used in event projectile collides with spawning character's own collision shape
@export var character_collision : CollisionShape3D

func _on_player_weapon_fired():
	normalised_direction()
	instantiate_projectile()

func normalised_direction() -> void:
	# Get the x and y rotations of the components of the player node tree
	# which handle mouse inputs (camera and head)
	#facing_angles.x = camera.rotation.x
	#facing_angles.y = head.rotation.y
	
	# Convert the angles into a unit vector, to give direction of fire
	#direction.x = cos(facing_angles.x) * cos(facing_angles.y)
	#direction.y = sin(facing_angles.y)
	#direction = direction.normalized()
	var camera_basis = camera.global_transform.basis
	direction = camera_basis.z.normalized()

func instantiate_projectile() -> void:
	var projectile_speed = player.pistol_projectile_speed
	var projectile_life_secs = player.pistol_projectile_life_secs
	var projectile_max_damage = player.pistol_projectile_max_damage
	
	var projectile_instance = projectile.instantiate()
	
	# Pass necessary data to the projectile
	projectile_instance.set_up_variables(direction, projectile_speed,
			projectile_life_secs, projectile_max_damage, character_collision)
	
	add_child(projectile_instance)
	
	# Tweak the spawn point of the projectile
	# so it lines up with the firing character's weapon animation
	var spawn_position = player.global_transform.origin + Vector3(
		player.pistol_projectile_spawn_x_offset,
		player.pistol_projectile_spawn_y_offset,
		player.pistol_projectile_spawn_z_offset
	)
	projectile_instance.global_transform.origin = spawn_position
