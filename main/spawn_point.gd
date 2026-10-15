@icon("res://common/icons/spawn_point_icon.svg")
class_name SpawnPoint
extends Marker3D

## Where the character spawner places a character. Only the x and z position
## are used: the character is set on the terrain surface.

@export var scene: PackedScene
## How far above the terrain surface the character appears
@export var height_above_ground: float = 0.5
