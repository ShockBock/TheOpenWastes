extends Node3D

## Spawns a character at each SpawnPoint child, standing on the terrain.

signal player_spawned(player: Player)

@export var terrain: TerrainManager


func _on_main_sequence_spawn_characters_signal() -> void:
	for spawn_point: Node in get_children():
		if spawn_point is SpawnPoint:
			spawn(spawn_point)


func spawn(spawn_point: SpawnPoint) -> void:
	var character: Node3D = spawn_point.scene.instantiate()
	var x: float = spawn_point.position.x
	var z: float = spawn_point.position.z
	character.position = Vector3(x, terrain.height_at(x, z) + spawn_point.height_above_ground, z)
	add_child(character)
	if character is Player:
		player_spawned.emit(character)
