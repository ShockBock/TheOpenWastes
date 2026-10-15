extends Node3D

## Streams terrain chunks around the player.
##
## Ported from the proc_terrain project. The player does not exist until the
## buildings are placed, so the area around the origin is generated in one go
## first; those chunks are never unloaded, so buildings and NPCs always have
## ground beneath them. Once the player spawns, chunks stream in and out
## around them, generated on worker threads.

signal landscape_complete

## Plug terrain chunk scene here
@export var chunk_scene: PackedScene
## Found via the "player" group if left empty, since the player is spawned
## after the terrain.
@export var player: CharacterBody3D
@export var chunk_size: int = 64
## Vertical scale of the terrain in metres. Heights stay within roughly
## ±0.7 × amplitude of y = 0. The earth/rock texture blend scales with it.
@export_range(0.0, 100.0, 0.5) var amplitude: float = 15.0
## How many chunks out from player
@export var render_distance: int = 3
## Most finished chunks added to the scene per frame. Their mesh and
## collision are created on the main thread.
@export var chunks_per_frame: int = 1
## Most chunks generating on worker threads at once
@export var max_generating_chunks: int = 4
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

## Chunks within render distance of the player, updated every frame
var needed_chunks: Dictionary[Vector2i, bool] = {}

## Queue of chunks waiting to be generated, nearest to the player first
var spawn_queue: Array[Vector2i] = []

## Chunks generating on worker threads.
## Keys: Vector2i (chunk grid coords), Values: {"task_id": int, "chunk": Node3D}
var generating: Dictionary[Vector2i, Dictionary] = {}

## The chunk scene's material, with its earth/rock height blend scaled to
## amplitude. Shared by every chunk.
var terrain_material: ShaderMaterial


func _on_main_sequence_generate_terrain_signal() -> void:
	generate_initial_area()


func generate_initial_area() -> void:
	if world_seed == 0:
		world_seed = randi_range(1, 50000)

	var first: int = int(floor(-initial_area_half_extent / chunk_size))
	var last: int = int(ceil(initial_area_half_extent / chunk_size)) - 1
	var keys: Array[Vector2i] = []
	var new_chunks: Array[Node3D] = []
	for x in range(first, last + 1):
		for z in range(first, last + 1):
			keys.append(Vector2i(x, z))
			new_chunks.append(create_chunk())

	# Generate the whole area in parallel. Nothing can be placed until the
	# ground exists, so wait for it to finish.
	var group_id: int = WorkerThreadPool.add_group_task(
		func(i: int) -> void: new_chunks[i].build_chunk_data(keys[i].x, keys[i].y), keys.size()
	)
	WorkerThreadPool.wait_for_group_task_completion(group_id)

	for i in range(keys.size()):
		add_chunk(keys[i], new_chunks[i])
		permanent_chunks[keys[i]] = true

	# Give the physics server a frame to register the chunks' collision
	# shapes before buildings and characters raycast down onto them.
	await get_tree().physics_frame
	landscape_complete.emit()


func _process(_delta: float) -> void:
	update_chunks()
	start_generating_chunks()
	add_generated_chunks()


func _exit_tree() -> void:
	# Worker threads must finish before the chunks they are building are freed
	for job: Dictionary in generating.values():
		WorkerThreadPool.wait_for_task_completion(job["task_id"])
		job["chunk"].free()
	generating.clear()


func update_chunks() -> void:
	if player == null:
		player = get_tree().get_first_node_in_group("player") as CharacterBody3D
		if player == null:
			return

	var player_chunk: Vector2i = Vector2i(
		int(floor(player.global_position.x / chunk_size)),
		int(floor(player.global_position.z / chunk_size))
	)

	needed_chunks.clear()
	var queue_changed: bool = false
	for x in range(player_chunk.x - render_distance, player_chunk.x + render_distance + 1):
		for z in range(player_chunk.y - render_distance, player_chunk.y + render_distance + 1):
			var key: Vector2i = Vector2i(x, z)
			needed_chunks[key] = true
			if not chunks.has(key) and not generating.has(key) and not spawn_queue.has(key):
				spawn_queue.append(key)
				queue_changed = true

	if queue_changed:
		spawn_queue.sort_custom(
			func(a: Vector2i, b: Vector2i) -> bool:
				return (a - player_chunk).length_squared() < (b - player_chunk).length_squared()
		)

	# Drop queued chunks the player has moved away from
	spawn_queue = spawn_queue.filter(func(key: Vector2i) -> bool: return needed_chunks.has(key))

	# Remove chunks that are no longer needed
	for key in chunks.keys():
		if not needed_chunks.has(key) and not permanent_chunks.has(key):
			chunks[key].queue_free()
			chunks.erase(key)


func start_generating_chunks() -> void:
	while generating.size() < max_generating_chunks and spawn_queue.size() > 0:
		var key: Vector2i = spawn_queue.pop_front()
		var chunk: Node3D = create_chunk()
		var task_id: int = WorkerThreadPool.add_task(chunk.build_chunk_data.bind(key.x, key.y))
		generating[key] = {"task_id": task_id, "chunk": chunk}


func add_generated_chunks() -> void:
	var added: int = 0
	for key: Vector2i in generating.keys():
		if added >= chunks_per_frame:
			return
		var job: Dictionary = generating[key]
		if not WorkerThreadPool.is_task_completed(job["task_id"]):
			continue
		WorkerThreadPool.wait_for_task_completion(job["task_id"])
		generating.erase(key)
		if needed_chunks.has(key):
			add_chunk(key, job["chunk"])
			added += 1
		else:
			# The player moved away while it was generating
			job["chunk"].free()


## Instantiates a chunk ready for build_chunk_data(). It is not added to the
## tree, so a worker thread can safely use it.
func create_chunk() -> Node3D:
	var chunk: Node3D = chunk_scene.instantiate()
	if terrain_material == null:
		terrain_material = scaled_terrain_material(chunk)

	# Pass settings to chunk
	chunk.use_heightmap_collision = use_heightmap_collision
	chunk.chunk_size = chunk_size
	chunk.custom_seed = world_seed
	chunk.height_scale = amplitude
	chunk.material_override = terrain_material
	chunk.configure_noise()
	return chunk


func add_chunk(key: Vector2i, chunk: Node3D) -> void:
	add_child(chunk)
	chunk.apply_chunk_data()

	# Position chunk in world space
	chunk.global_position = Vector3(key.x * chunk_size, 0, key.y * chunk_size)

	chunks[key] = chunk


## The shader blends earth to rock between min_height and max_height, which
## the chunk scene sets for its own height_scale. Scale them to amplitude so
## the blend stays in proportion to the hills. Works on a copy, as the
## scene's material is shared by every instance of the scene.
func scaled_terrain_material(chunk: Node3D) -> ShaderMaterial:
	var material: ShaderMaterial = chunk.material_override.duplicate()
	# Keep the blend range above zero, as the shader divides by it
	var ratio: float = max(amplitude, 0.1) / chunk.height_scale
	for parameter in ["min_height", "max_height"]:
		material.set_shader_parameter(parameter, material.get_shader_parameter(parameter) * ratio)
	return material
