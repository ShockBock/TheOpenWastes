@icon("res://common/icons/pistol_icon.png")
extends Node

## Spawns the shotgun monk's pellets, each with a random deviation from the
## aiming line, and passes them their speed, lifetime and damage.

@export var projectile_scene: PackedScene
@export var npc: NPC
@export var projectile_spawn_point: Marker3D


func _on_shotgun_monk_fire_spawn_projectiles() -> void:
	var stats: NPCStats = npc.stats
	var aim_point: Vector3 = npc.target.global_position
	aim_point.y -= stats.target_y_offset_metres
	var aim_direction: Vector3 = (aim_point - npc.global_position).normalized()

	for i in stats.projectiles:
		var spread: Vector3 = Vector3(
			randf_range(-stats.projectile_spread, stats.projectile_spread),
			randf_range(-stats.projectile_spread, stats.projectile_spread),
			randf_range(-stats.projectile_spread, stats.projectile_spread),
		)
		spawn_projectile(aim_direction + spread, stats)


func spawn_projectile(direction: Vector3, stats: NPCStats) -> void:
	var projectile: Node3D = projectile_scene.instantiate()
	(
		projectile
		. set_up(
			direction,
			npc,
			stats.projectile_speed,
			stats.projectile_life_secs,
			stats.projectile_max_damage,
		)
	)
	add_child(projectile)
	projectile.global_position = projectile_spawn_point.global_position
