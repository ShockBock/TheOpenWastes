extends Control

@export_file("*.tscn") var game_scene: String
@export_file("*.tscn") var options_scene: String


func _on_start_button_pressed() -> void:
	get_tree().change_scene_to_file(game_scene)


func _on_options_button_pressed() -> void:
	get_tree().change_scene_to_file(options_scene)


func _on_exit_button_pressed() -> void:
	get_tree().quit()
