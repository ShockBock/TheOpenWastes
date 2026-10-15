extends Control

@export_file("*.tscn") var main_menu_scene: String


func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_main_menu_button_pressed() -> void:
	get_tree().change_scene_to_file(main_menu_scene)
