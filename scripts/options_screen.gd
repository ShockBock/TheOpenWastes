extends Control

func _on_main_menu_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Miscellaneous/start_screen.tscn")


func _on_invert_mouse_button_toggled(toggled_on):
	if toggled_on:
		global.mouse_inverted = true
	else:
		global.mouse_inverted = false
