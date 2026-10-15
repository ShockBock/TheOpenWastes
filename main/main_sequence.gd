extends Node3D

## Runs the game's start-up sequence: terrain, then buildings, then
## characters. Also handles leaving the game, on death or on request.

signal generate_terrain_signal
signal place_buildings_signal
signal spawn_characters_signal

@export_file("*.tscn") var death_screen: String
@export_file("*.tscn") var main_menu: String


func _ready() -> void:
	generate_terrain_signal.emit()


func _on_terrain_landscape_complete() -> void:
	place_buildings_signal.emit()


func _on_building_placer_buildings_complete() -> void:
	spawn_characters_signal.emit()


func _on_character_spawner_player_spawned(player: Player) -> void:
	player.died.connect(_on_player_died)


func _on_player_died() -> void:
	get_tree().change_scene_to_file.call_deferred(death_screen)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("exit"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		get_tree().change_scene_to_file(main_menu)
