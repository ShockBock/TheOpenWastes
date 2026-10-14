extends Node3D

## Streams terrain chunks around the player.
##
## Ported from the proc_terrain project. The player does not exist until the
## buildings are placed, so the area around the origin is generated in one go
## first; those chunks are never unloaded, so buildings and NPCs always have
## ground beneath them. Once the player spawns, chunks stream in and out
## around them.

signal landscape_complete

## Plug terrain chunk scene here
@export var chunk_scene: PackedScene
## Found via the "player" group if left empty, since the player is spawned
## after the terrain.
@export var player: CharacterBody3D
@export var chunk_size: int = 64
## How many chunks out from player
@export var render_distance: int = 3
## Limit streaming
@export var chunks_per_frame: int = 1
## Half the width, in metres, of the square around the origin that is
## generated before buildings and characters are placed.
@export var initial_area_half_extent: float = 128.0
## Shared by every chunk so their edges line up. 0 = random each run.
@export var world_seed: int = 0

## Toggle collision type: false = Concave, true = HeightMap.
## Use heightmap for simple terrains and concave for more complex geometry (cliffs etc.)
@export var use_heightmap_collision: bool = false

## Dictionary of active chunks
## Keys: Vector2i (chunk grid coords), Values: Node3D (terrain_chunk instance)
var chunks: Dictionary[Vector2i, Node3D] = {}

## Chunks from the initial area, which are never unloaded
var permanent_chunks: Dictionary[Vector2i, bool] = {}

## Queue of chunks waiting to spawn
var spawn_queue: Array[Vector2i] = []


func _on_main_sequence_generate_terrain_signal() -> void:
	generate_initial_area()


func generate_initial_area() -> void:
	if world_seed == 0:
		world_seed = randi_range(1, 50000)

	var first: int = int(floor(-initial_area_half_extent / chunk_size))
	var last: int = int(ceil(initial_area_half_extent / chunk_size)) - 1
	for x in range(first, last + 1):
		for z in range(first, last + 1):
			spawn_chunk(x, z)
			permanent_chunks[Vector2i(x, z)] = true

	# Give the physics server a frame to register the chunks' collision
	# shapes before buildings and characters raycast down onto them.
	await get_tree().physics_frame
	landscape_complete.emit()


func _process(_delta: float) -> void:
	update_chunks()
	process_chunk_queue()


func update_chunks() -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player") as CharacterBody3D
		if player == null:
			return

	var player_chunk_x: int = int(floor(player.global_position.x / chunk_size))
	var player_chunk_z: int = int(floor(player.global_position.z / chunk_size))

	# Tracks which chunks we still need this frame
	var needed_chunks: Dictionary[Vector2i, bool] = {}

	for x in range(player_chunk_x - render_distance, player_chunk_x + render_distance + 1):
		for z in range(player_chunk_z - render_distance, player_chunk_z + render_distance + 1):
			var key: Vector2i = Vector2i(x, z)
			needed_chunks[key] = true
			if not chunks.has(key) and not spawn_queue.has(key):
				spawn_queue.append(key)

	# Remove chunks that are no longer needed
	for key in chunks.keys():
		if not needed_chunks.has(key) and not permanent_chunks.has(key):
			chunks[key].queue_free()
			chunks.erase(key)


func process_chunk_queue() -> void:
	var spawned: int = 0
	while spawned < chunks_per_frame and spawn_queue.size() > 0:
		var key: Vector2i = spawn_queue.pop_front()
		if not chunks.has(key):
			spawn_chunk(key.x, key.y)
			spawned += 1


func spawn_chunk(x: int, z: int) -> void:
	var chunk: Node = chunk_scene.instantiate()

	# Pass settings to chunk before _ready() sets up its noise
	chunk.use_heightmap_collision = use_heightmap_collision
	chunk.chunk_size = chunk_size
	chunk.custom_seed = world_seed
	add_child(chunk)

	# Generate terrain at given coords
	chunk.generate_chunk(x, z)

	# Position chunk in world space
	chunk.global_position = Vector3(x * chunk_size, 0, z * chunk_size)

	chunks[Vector2i(x, z)] = chunk
