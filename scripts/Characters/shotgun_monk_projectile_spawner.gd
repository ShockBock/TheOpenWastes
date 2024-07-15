@icon("res://images/Icons/pistol_icon.png")

extends Node

var projectile = preload("res://Scenes/Miscellaneous/projectile_tracer.tscn")

var direction: Vector3
var projectile_spread: Vector3

@onready var parent: CharacterBody3D = get_parent()
@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")

# Used in event projectile collides with spawning character's own collision shape
@export var character_collision: CollisionShape3D

func _on_shotgun_monk_fire_spawn_projectiles():
	normalised_direction_to_target()
	for projectile_count in parent.projectiles:
		projectile_spread.x = randf_range(-parent.projectile_spread, parent.projectile_spread)
		projectile_spread.y = randf_range(-parent.projectile_spread, parent.projectile_spread)
		projectile_spread.z = randf_range(-parent.projectile_spread, parent.projectile_spread)
		instantiate_projectile()


func normalised_direction_to_target() -> void:
	var player_target: Vector3 = player.global_position
	player_target.y -= parent.target_y_offset_metres
	direction = parent.global_position - player_target
	direction = direction.normalized()


func instantiate_projectile() -> void:
	var projectile_speed = parent.projectile_speed
	direction += projectile_spread
	direction = direction.normalized()
	var projectile_life_secs = parent.projectile_life_secs
	var projectile_max_damage = parent.projectile_max_damage
	
	var projectile_instance = projectile.instantiate()
	
	# Pass necessary data to the projectile
	projectile_instance.set_up_variables(direction, projectile_speed,
			projectile_life_secs, projectile_max_damage, character_collision)
	
	# Tweak the spawn point of the projectile
	# so it lines up with the firing character's weapon animation
	projectile_instance.position.x = parent.global_position.x \
			+ parent.projectile_spawn_x_offset
	projectile_instance.position.y = parent.global_position.y \
			+ parent.projectile_spawn_y_offset
	projectile_instance.position.z = parent.global_position.z \
			+ parent.projectile_spawn_z_offset
	add_child(projectile_instance)
