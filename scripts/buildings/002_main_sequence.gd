@icon("res://images/Icons/building_icon.png")

extends Node3D

## Co-ordinates the procedural generation of Building002.

@export_group("Plug-in nodes")
@export var data_node: Node
@export var assign_wall_sections_node: Node
@export var instantiate_wall_sections_node: Node
@export var instantiate_stairwell_node: Node

## Stores the number of storeys this instance of Building002 will have.
var storeys: int
var building_component_dictionary = {
	"002_foundation_base" : preload("res://Scenes/buildings/building002assets/002_foundation_base.tscn"),
	}

func _ready():
	storeys = randi_range(1, data_node.max_number_of_storeys)
	instantiate_base()


func instantiate_base() -> void:
	var foundation_base = building_component_dictionary["002_foundation_base"]
	var foundation_base_instance = foundation_base.instantiate()
	add_child(foundation_base_instance)


func floorplan_complete() -> void:
	assign_wall_sections_node.sequence()


func wall_arrays_complete() -> void:
	for storey in storeys:
		instantiate_wall_sections_node.sequence(storey)
	wall_instances_complete.call_deferred()


func wall_instances_complete() -> void:
	for storey in storeys:
		instantiate_stairwell_node.sequence(storey)
