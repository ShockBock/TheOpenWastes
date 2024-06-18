extends Node3D

signal generate_terrain_signal
signal place_buildings_signal

func _ready():
	main_sequence_begin()

func main_sequence_begin():
	emit_signal("generate_terrain_signal")

func _on_terrain_landscape_complete():
	place_buildings()

func place_buildings():
	emit_signal("place_buildings_signal")
