extends Control

func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://TheOpenWastes.tscn")


func _on_options_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/Miscellaneous/options_screen.tscn")


func _on_exit_button_pressed():
	get_tree().quit()
