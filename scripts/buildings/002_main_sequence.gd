@icon("res://images/Icons/building_icon.png")

extends Node3D

## Co-ordinates the procedural generation of Building002.

enum CellState { EMPTY, OCCUPIED }

@export_group("Plug-in nodes")
@export var data_node: Node
@export var assign_wall_sections_node: Node
@export var instantiate_wall_sections_node: Node

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


func floorplan_complete() -> void:
	assign_wall_sections_node.sequence()


## Pass completed wall selection to 002_instantiate_wall_section node
## and initialise its sequence.
func wall_arrays_finished() -> void:
	for storey in randi_range(1, data_node.max_number_of_storeys):
		instantiate_wall_sections_node.sequence(storey)
