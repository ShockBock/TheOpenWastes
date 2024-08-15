extends Node3D

## Orchestrates the generation of the game's main nodes.
##
## Responsible for generating: terrain, buildings and characters.

signal start_screen_signal
signal generate_terrain_signal
signal place_buildings_signal
signal spawn_characters_signal

@onready var DeathScreen:= preload("res://Scenes/ui/death_screen.tscn")

func _ready():
	main_sequence_begin()


func main_sequence_begin() -> void:
	generate_terrain()


func generate_terrain() -> void:
	emit_signal("generate_terrain_signal")


func _on_terrain_landscape_complete() -> void:
	place_buildings()


func place_buildings() -> void:
	emit_signal("place_buildings_signal")


func _on_building_placer_buildings_complete() -> void:
	emit_signal("spawn_characters_signal")


func end_game() -> void:
	get_tree().change_scene_to_file("res://Scenes/ui/death_screen.tscn")
