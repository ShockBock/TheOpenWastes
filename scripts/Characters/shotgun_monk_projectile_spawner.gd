extends Node

var projectile = preload("res://Scenes/Miscellaneous/projectile_tracer.tscn")

var direction : Vector3
var projectile_spread : Vector3

@onready var parent : CharacterBody3D = get_parent()
@onready var player : CharacterBody3D = get_tree().get_first_node_in_group("player")

@export var character_collision : CollisionShape3D

func _on_shotgun_monk_fire_spawn_projectiles():
	normalised_direction_to_target()
	for projectile_count in parent.projectiles:
		projectile_spread.x = randf_range(-parent.projectile_spread, parent.projectile_spread)
		projectile_spread.y = randf_range(-parent.projectile_spread, parent.projectile_spread)
		projectile_spread.z = randf_range(-parent.projectile_spread, parent.projectile_spread)
		instantiate_projectile()


func normalised_direction_to_target() -> void:
	direction = parent.global_position - player.global_position
	direction = direction.normalized()


func instantiate_projectile() -> void:
	var projectile_speed = parent.projectile_speed
	var projectile_life_secs = parent.projectile_life_secs
	var projectile_instance = projectile.instantiate()
	direction += projectile_spread
	direction = direction.normalized()
	projectile_instance.set_up_variables(direction, projectile_speed,
			projectile_life_secs, character_collision)
	projectile_instance.position.x = parent.global_position.x \
			+ parent.projectile_spawn_x_offset
	projectile_instance.position.y = parent.global_position.y \
			+ parent.projectile_spawn_y_offset
	projectile_instance.position.z = parent.global_position.z \
			+ parent.projectile_spawn_z_offset
	add_child(projectile_instance)
