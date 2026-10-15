extends MeshInstance3D

## One square of streamed terrain, generated from noise.
##
## Ported from the proc_terrain project. The chunk's origin is its corner,
## so chunk (x, z) covers world x..x+chunk_size, z..z+chunk_size.
##
## Generation is split in two so the slow part can run on a worker thread:
## build_chunk_data() only does maths on this chunk's own settings and
## arrays, before the chunk enters the tree. apply_chunk_data() then creates
## the mesh and collision shape on the main thread, as the rendering and
## physics servers must not be called from worker threads.

@export var chunk_size: int = 64
## Grid squares along each edge. chunk_size / subdivisions = metres per square.
@export var subdivisions: int = 64
@export var noise_scale: float = 20.0
## Set by terrain_manager from its amplitude.
@export var height_scale: float = 15.0
## Set by terrain_manager so neighbouring chunks share the same noise.
@export var custom_seed: int = 1337

## Controlled externally by terrain_manager
var use_heightmap_collision: bool = false

## Noise generator
var noise: FastNoiseLite = FastNoiseLite.new()

## Physics members
var static_body: StaticBody3D
var collision_shape: CollisionShape3D

## Output of build_chunk_data(), consumed by apply_chunk_data()
var chunk_data: Dictionary = {}


## Called by terrain_manager once custom_seed is set, before generation.
func configure_noise() -> void:
	noise.seed = custom_seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.05


func _ready() -> void:
	# Set up physics once
	static_body = StaticBody3D.new()
	collision_shape = CollisionShape3D.new()
	static_body.add_child(collision_shape)
	add_child(static_body)


func height_at(world_x: float, world_z: float) -> float:
	return noise.get_noise_2d(world_x / noise_scale, world_z / noise_scale) * height_scale


## Generates the chunk in one go on the calling (main) thread.
func generate_chunk(chunk_x: int, chunk_z: int) -> void:
	build_chunk_data(chunk_x, chunk_z)
	apply_chunk_data()


## Safe to run on a worker thread.
func build_chunk_data(chunk_x: int, chunk_z: int) -> void:
	var origin_x: float = chunk_x * chunk_size
	var origin_z: float = chunk_z * chunk_size
	var step: float = float(chunk_size) / subdivisions
	var verts_per_side: int = subdivisions + 1

	# Heights include a one-vertex border from the neighbouring chunks, so
	# normals at the edges match on both sides of a seam.
	var border_side: int = verts_per_side + 2
	var heights: PackedFloat32Array = PackedFloat32Array()
	heights.resize(border_side * border_side)
	for z: int in range(border_side):
		for x: int in range(border_side):
			heights[z * border_side + x] = height_at(
					origin_x + (x - 1) * step, origin_z + (z - 1) * step)

	var surface_tool: SurfaceTool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)

	for z: int in range(verts_per_side):
		for x: int in range(verts_per_side):
			var i: int = (z + 1) * border_side + (x + 1)
			var normal: Vector3 = Vector3(
					heights[i - 1] - heights[i + 1],
					2.0 * step,
					heights[i - border_side] - heights[i + border_side]).normalized()
			surface_tool.set_normal(normal)
			surface_tool.set_uv(Vector2(x, z) / subdivisions)
			surface_tool.add_vertex(Vector3(x * step, heights[i], z * step))

	# Two triangles per grid square, wound clockwise when seen from above
	for z: int in range(subdivisions):
		for x: int in range(subdivisions):
			var i: int = z * verts_per_side + x
			surface_tool.add_index(i)
			surface_tool.add_index(i + 1)
			surface_tool.add_index(i + verts_per_side)
			surface_tool.add_index(i + 1)
			surface_tool.add_index(i + verts_per_side + 1)
			surface_tool.add_index(i + verts_per_side)

	# Tangents are needed by the shader's normal maps
	surface_tool.generate_tangents()
	var mesh_arrays: Array = surface_tool.commit_to_arrays()

	chunk_data = {"mesh_arrays": mesh_arrays, "step": step}
	if use_heightmap_collision:
		chunk_data["heightmap"] = build_heightmap(heights, border_side, step)
	else:
		chunk_data["faces"] = build_faces(mesh_arrays)


## Main thread only, once the chunk is in the tree.
func apply_chunk_data() -> void:
	var new_mesh: ArrayMesh = ArrayMesh.new()
	new_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, chunk_data["mesh_arrays"])
	mesh = new_mesh

	if use_heightmap_collision:
		collision_option_a_heightmap(chunk_data["heightmap"], chunk_data["step"])
	else:
		collision_option_b_concave(chunk_data["faces"])
	chunk_data = {}


## HeightMapShape3D cells are 1 unit apart, so heights are divided by step
## here and the shape is scaled back up by step when applied.
func build_heightmap(heights: PackedFloat32Array, border_side: int, step: float) -> PackedFloat32Array:
	var size: int = subdivisions + 1
	var map: PackedFloat32Array = PackedFloat32Array()
	map.resize(size * size)
	for z: int in range(size):
		for x: int in range(size):
			map[z * size + x] = heights[(z + 1) * border_side + (x + 1)] / step
	return map


## Expands the indexed mesh into the triangle list ConcavePolygonShape3D needs.
func build_faces(mesh_arrays: Array) -> PackedVector3Array:
	var vertices: PackedVector3Array = mesh_arrays[Mesh.ARRAY_VERTEX]
	var indices: PackedInt32Array = mesh_arrays[Mesh.ARRAY_INDEX]
	var faces: PackedVector3Array = PackedVector3Array()
	faces.resize(indices.size())
	for i: int in range(indices.size()):
		faces[i] = vertices[indices[i]]
	return faces


## Pros: Fast, memory-efficient, perfect for large terrains, predictable physics.
## Cons: Only works for terrains (no overhangs, caves, or arbitrary meshes).
func collision_option_a_heightmap(map: PackedFloat32Array, step: float) -> void:
	var shape: HeightMapShape3D = HeightMapShape3D.new()
	shape.map_width = subdivisions + 1
	shape.map_depth = subdivisions + 1
	shape.map_data = map
	collision_shape.shape = shape
	# HeightMapShape3D is centred on its node; the chunk's origin is its corner
	collision_shape.scale = Vector3.ONE * step
	collision_shape.position = Vector3(chunk_size * 0.5, 0, chunk_size * 0.5)


## Pros: Can handle any shape (including caves, cliffs, overhangs).
## Cons: Slower, more expensive for physics, less stable for large or complex terrain meshes.
func collision_option_b_concave(faces: PackedVector3Array) -> void:
	var shape: ConcavePolygonShape3D = ConcavePolygonShape3D.new()
	shape.set_faces(faces)
	collision_shape.shape = shape
	collision_shape.scale = Vector3.ONE
	collision_shape.position = Vector3.ZERO
