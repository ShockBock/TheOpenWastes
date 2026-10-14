extends MeshInstance3D

## One square of streamed terrain, generated from noise.
##
## Ported from the proc_terrain project. The chunk's origin is its corner,
## so chunk (x, z) covers world x..x+chunk_size, z..z+chunk_size.

@export var chunk_size: int = 64
## Grid squares along each edge. chunk_size / subdivisions = metres per square.
@export var subdivisions: int = 64
@export var noise_scale: float = 20.0
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


func _ready() -> void:
	# Configure noise
	noise.seed = custom_seed
	noise.noise_type = FastNoiseLite.TYPE_PERLIN
	noise.frequency = 0.05

	# Set up physics once
	static_body = StaticBody3D.new()
	collision_shape = CollisionShape3D.new()
	static_body.add_child(collision_shape)
	add_child(static_body)


func height_at(world_x: float, world_z: float) -> float:
	return noise.get_noise_2d(world_x / noise_scale, world_z / noise_scale) * height_scale


func generate_chunk(chunk_x: int, chunk_z: int) -> void:
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
	var new_mesh: ArrayMesh = surface_tool.commit()
	mesh = new_mesh

	if use_heightmap_collision:
		collision_option_a_heightmap(heights, border_side, step)
	else:
		collision_option_b_concave(new_mesh)


## Pros: Fast, memory-efficient, perfect for large terrains, predictable physics.
## Cons: Only works for terrains (no overhangs, caves, or arbitrary meshes).
func collision_option_a_heightmap(heights: PackedFloat32Array, border_side: int, step: float) -> void:
	var size: int = subdivisions + 1
	var map: PackedFloat32Array = PackedFloat32Array()
	map.resize(size * size)
	# HeightMapShape3D cells are 1 unit apart, so heights are divided by
	# step here and the shape is scaled back up by step below.
	for z: int in range(size):
		for x: int in range(size):
			map[z * size + x] = heights[(z + 1) * border_side + (x + 1)] / step

	var shape: HeightMapShape3D = HeightMapShape3D.new()
	shape.map_width = size
	shape.map_depth = size
	shape.map_data = map
	collision_shape.shape = shape
	# HeightMapShape3D is centred on its node; the chunk's origin is its corner
	collision_shape.scale = Vector3.ONE * step
	collision_shape.position = Vector3(chunk_size * 0.5, 0, chunk_size * 0.5)


## Pros: Can handle any shape (including caves, cliffs, overhangs).
## Cons: Slower, more expensive for physics, less stable for large or complex terrain meshes.
func collision_option_b_concave(new_mesh: ArrayMesh) -> void:
	collision_shape.shape = new_mesh.create_trimesh_shape()
	collision_shape.scale = Vector3.ONE
	collision_shape.position = Vector3.ZERO
