extends Node3D

## Places buildings on a regular grid centred on the origin, each standing on
## the terrain.

signal buildings_complete

@export var terrain: TerrainManager
@export var building_scene: PackedScene
@export_range(0, 20) var max_number_buildings_on_x_axis: int = 12
@export_range(0, 20) var max_number_buildings_on_z_axis: int = 12
@export var distance_between_buildings_metres: int = 20
@export_range(0.0, 2.0, 0.01) var y_offset_metres: float = 1.0


func _on_main_sequence_place_buildings_signal() -> void:
	for x in max_number_buildings_on_x_axis:
		for z in max_number_buildings_on_z_axis:
			place_building(x, z)
	buildings_complete.emit.call_deferred()


func place_building(grid_x: int, grid_z: int) -> void:
	var x: float = (
		(grid_x - max_number_buildings_on_x_axis / 2.0) * distance_between_buildings_metres
	)
	var z: float = (
		(grid_z - max_number_buildings_on_z_axis / 2.0) * distance_between_buildings_metres
	)
	var building: Node3D = building_scene.instantiate()
	building.position = Vector3(x, terrain.height_at(x, z) + y_offset_metres, z)
	add_child(building)
