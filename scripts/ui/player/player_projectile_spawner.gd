@icon("res://images/Icons/pistol_icon.png")

extends Node

var projectile = preload("res://Scenes/miscellaneous/projectile_tracer.tscn")

var direction: Vector3

@onready var player = get_tree().get_first_node_in_group("player") as CharacterBody3D
@onready var camera = player.get_node("Head/Camera3D") as Camera3D
@onready var own_collision_mesh = player.get_node("Player_CollisionShape3D") as CollisionShape3D
@onready var projectile_instance: Node3D

@export var projectile_data: Node
@export var projectile_spawn_point: Marker3D

func _on_weapon_fired() -> void:
	normalised_direction()
	instantiate_projectile()


func normalised_direction() -> void:
	direction = camera.global_transform.basis.z.normalized()


func instantiate_projectile() -> void:
	projectile_instance = projectile.instantiate()
	
	# Pass necessary data to the projectile
	projectile_instance.set_up_variables(
		direction,
		own_collision_mesh,
		projectile_data.projectile_speed,
		projectile_data.projectile_life_secs,
		projectile_data.projectile_max_damage,
	)
	
	add_child(projectile_instance)
	projectile_instance.global_transform.origin = projectile_spawn_point.global_transform.origin

