extends Node3D

## Terrain generation.
##
## Creates a mesh, subdivides it, applies noise to simulate differential amplitude,
## applies the mesh to a MeshInstance3D and creates a correspnding CollisionShape3D.
## [br]
## Based on Procedural Terrain Generation: Displacement & Collisions 
## by DitzyNinja's Godojo.
##
## @tutorial: https://www.youtube.com/watch?v=OUnJEaatl2Q

signal landscape_complete

@export_group("Plug-in nodes")
@export var mesh_instance_3d: MeshInstance3D
@export var collision_shape_3d: CollisionShape3D

@export_group("Mesh characteristics")
@export var size : int = 64
@export var subdivide : int = 63
@export var amplitude : int = 5

@export_group("Noise")
@export var noise : FastNoiseLite = FastNoiseLite.new()

func _on_main_sequence_generate_terrain_signal():
	generate_terrain()

func generate_terrain():
	var plane_mesh = PlaneMesh.new()
	plane_mesh.size = Vector2(size,size)
	plane_mesh.subdivide_depth = subdivide
	plane_mesh.subdivide_width = subdivide
	
	var surface_tool = SurfaceTool.new()
	surface_tool.create_from(plane_mesh,0)
	var data = surface_tool.commit_to_arrays()
	var vertices = data[ArrayMesh.ARRAY_VERTEX]
	
	noise.seed = randi_range(0, 50000)
	
	for i in vertices.size():
		var vertex = vertices[i]
		vertices[i].y = noise.get_noise_2d(vertex.x,vertex.z) * amplitude
	data[ArrayMesh.ARRAY_VERTEX] = vertices
	
	var array_mesh = ArrayMesh.new()
	array_mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES,data)
	
	surface_tool.create_from(array_mesh,0)
	surface_tool.generate_normals()
	
	mesh_instance_3d.mesh = surface_tool.commit()
	collision_shape_3d.shape = array_mesh.create_trimesh_shape()
	
	# Give the $DitzyTerrain/CollisionShape3D time 
	# to instantiate the collision mesh before placing buildings
	_emit_landscape_complete.call_deferred()

func _emit_landscape_complete():
	landscape_complete.emit()
