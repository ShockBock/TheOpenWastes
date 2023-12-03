extends Node

@export var chance_of_placing_building_element : float = 0.5

# Set up dictionary to store which cells are filled with building elements and which not

var building_cell = {
	"top_left" : "empty", "top_middle" : "empty", "top_right" : "empty",
	"middle_left" : "empty", "middle_centre" : "built", "middle_right" : "empty",
	"bottom_left" : "empty", "bottom_middle" : "empty", "bottom_right" : "empty"
}

# Set up dictionary to store where the building elements are instantiated in world space

var cell_locations = [
	Vector3(4, 0, -4),
	Vector3(0, 0, -4),
	Vector3(-4, 0, -4),
	Vector3(-4, 0, 0),
	Vector3(-4, 0, 4),
	Vector3(0, 0, 4),
	Vector3(4, 0, 4),
	Vector3(4, 0, 0)
	]

# Called when the node enters the scene tree for the first time.
func _ready():
# Fill all cells at random, except the centre cell, which is always filled
	for cell in cell_locations:
		if randf() > chance_of_placing_building_element:
			# Insert code here to instantiate building element in cell
			# [code]
			
			#Update building_cell dictionary.
			building_cell[cell] = "built"
		else:
			pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass



