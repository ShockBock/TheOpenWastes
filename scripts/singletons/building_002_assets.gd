extends Node

## Singleton containing all preloads for Building002.

var walls_asset_array: Array = [
	preload("res://Scenes/buildings/building002assets/002_wall_windows_door.tscn"),
	preload("res://Scenes/buildings/building002assets/002_wall_blank.tscn"),
	preload("res://Scenes/buildings/building002assets/002_wall_windows_001.tscn"),
	preload("res://Scenes/buildings/building002assets/002_wall_windows_002.tscn"),
	preload("res://Scenes/buildings/building002assets/002_wall_windows_003.tscn"),
	]


var stairs_asset_dictionary: Dictionary = {
	"002_stairs_002_ground_floor": \
			preload("res://Scenes/buildings/building002assets/002_stairs_002_ground_floor.tscn"),
	"002_stairs_001": \
			preload("res://Scenes/buildings/building002assets/002_stairs_001.tscn"),
	"002_stairs_002": \
			preload("res://Scenes/buildings/building002assets/002_stairs_002.tscn"),
}


var foundation_stairs: PackedScene = \
		preload("res://Scenes/buildings/building002assets/002_foundation_stairs.tscn")


var wall_pillar: PackedScene = \
		preload("res://Scenes/buildings/building002assets/002_wall_pillar.tscn")
