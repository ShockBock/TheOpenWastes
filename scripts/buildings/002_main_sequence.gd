@icon("res://images/Icons/building_icon.png")

extends Node3D

## Co-ordinates the procedural generation of Building002.

enum CellState { EMPTY, OCCUPIED }

@export_group("Plug-in nodes")
@export var assign_wall_sections_node: Node
@export var instantiate_wall_sections_node: Node


## Stores the floorplan of the building in grid format,
## with each cell taking a CellState value.
var floorplan: Array = []

var building_component_dictionary = {
	"002_foundation_base" : preload("res://Scenes/buildings/building002assets/002_foundation_base.tscn"),
	}


# Called when the node enters the scene tree for the first time.
func _ready():
	instantiate_base()


func instantiate_base() -> void:
	var foundation_base = building_component_dictionary["002_foundation_base"]
	var foundation_base_instance = foundation_base.instantiate()
	add_child(foundation_base_instance)


func pass_floorplan(grid: Array) -> void:
	floorplan = grid
	assign_wall_sections_node.floorplan = grid
	assign_wall_sections_node.sequence()


## Pass completed wall selection to 002_instantiate_wall_section node
## and initialise its sequence.
func pass_walls_arrays(walls_array_x: Array, walls_array_y: Array) -> void:
	instantiate_wall_sections_node.floorplan = floorplan
	instantiate_wall_sections_node.walls_array_x = walls_array_x
	instantiate_wall_sections_node.walls_array_y = walls_array_y
	
	instantiate_wall_sections_node.sequence()
