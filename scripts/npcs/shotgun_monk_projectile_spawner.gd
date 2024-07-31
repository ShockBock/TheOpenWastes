@icon("res://images/Icons/pistol_icon.png")

## Handles instantiation of shotgun monk projectiles,
## gives the projectiles a random directional offset, as per a shotgun,
## and passes data such as damage and speed to the projectiles.

extends Node

var projectile = preload("res://Scenes/Miscellaneous/projectile_tracer.tscn")

var direction: Vector3
var projectile_spread: Vector3

@export var shotgun_monk: CharacterBody3D
@export var shotgun_monk_data: Node
@export var projectile_spawn_point: Marker3D
@export var own_collision: CollisionShape3D

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")

func _on_shotgun_monk_fire_spawn_projectiles():
	normalised_direction_to_target()
	for projectile_count in shotgun_monk_data.projectiles:
		calculate_offset_due_to_shotgun_spread()
		instantiate_projectile()


func normalised_direction_to_target() -> void:
	var player_target: Vector3 = player.global_position
	player_target.y -= shotgun_monk_data.target_y_offset_metres
	direction = shotgun_monk.global_position - player_target
	direction = direction.normalized()


func calculate_offset_due_to_shotgun_spread() -> void:
		projectile_spread.x = randf_range(-shotgun_monk_data.projectile_spread, shotgun_monk_data.projectile_spread)
		projectile_spread.y = randf_range(-shotgun_monk_data.projectile_spread, shotgun_monk_data.projectile_spread)
		projectile_spread.z = randf_range(-shotgun_monk_data.projectile_spread, shotgun_monk_data.projectile_spread)


func instantiate_projectile() -> void:
	var projectile_speed = shotgun_monk_data.projectile_speed
	direction += projectile_spread
	direction = direction.normalized()
	var projectile_life_secs = shotgun_monk_data.projectile_life_secs
	var projectile_max_damage = shotgun_monk_data.projectile_max_damage
	
	var projectile_instance = projectile.instantiate()
	
	# Pass necessary data to the projectile
	projectile_instance.set_up_variables(
		direction,
		own_collision,
		projectile_speed,
		projectile_life_secs,
		projectile_max_damage
		)
	
	add_child(projectile_instance)
	projectile_instance.global_transform.origin = projectile_spawn_point.global_transform.origin
