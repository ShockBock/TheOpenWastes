@icon("res://common/icons/pistol_icon.png")
extends Node

## Spawns a projectile in the direction the player is looking each time the
## weapon fires. Weapon-agnostic: speed, lifetime and damage come from stats.

@export var projectile_scene: PackedScene
@export var stats: WeaponStats
@export var projectile_spawn_point: Marker3D

@onready var player: CharacterBody3D = get_tree().get_first_node_in_group("player")


func _on_weapon_fired() -> void:
	var camera: Camera3D = get_viewport().get_camera_3d()
	var projectile: Node3D = projectile_scene.instantiate()
	(
		projectile
		. set_up(
			-camera.global_basis.z,
			player,
			stats.projectile_speed,
			stats.projectile_life_secs,
			stats.projectile_max_damage,
		)
	)
	add_child(projectile)
	projectile.global_position = projectile_spawn_point.global_position
